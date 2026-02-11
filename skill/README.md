# Wix MCP Documentation Navigator

A Claude Code skill that helps AI agents efficiently find Wix API documentation
through the Wix MCP tools, minimizing token usage and unnecessary API calls.

## What This Skill Does

When an agent needs Wix API information, the default MCP workflow calls
`WixREADME` (~1,950 tokens) then potentially `BrowseWixRESTDocsMenu` (107K+
characters / ~26,845 tokens). This skill short-circuits that by providing:

- **Per-domain recipe files** (`recipes/`) — 37 recipes split across 13 domain
  files, so only the relevant domain is loaded (~50-450 tokens instead of ~2,034)
- **Domain routing** (`domain-routing.md`) — Maps user intents to the right
  domain and provides optimized search terms
- **Decision tree** (`decision-tree.md`) — Step-by-step tool selection logic

The agent identifies the domain, loads only that domain's recipe file, and
calls `ReadFullDocsArticle` directly with the recipe URL. No `WixREADME`,
no `BrowseWixRESTDocsMenu`.

## Usage

- **Auto-invoked:** Claude loads the skill automatically when the task involves
  Wix API documentation
- **Manual:** Type `/wix-mcp` in Claude Code

## Performance Benchmarks

### Raw MCP Response Sizes (measured)

| Tool | Chars | ~Tokens |
|------|------:|--------:|
| `WixREADME()` | ~7,800 | ~1,950 |
| `BrowseWixRESTDocsMenu` (no URL) | 107,381 | ~26,845 |
| `BrowseWixRESTDocsMenu` (stores domain) | 94,439 | ~23,610 |
| `SearchWixRESTDocumentation` (5 results) | ~3,000 | ~750 |
| `ReadFullDocsArticle` (typical recipe) | ~8,000 | ~2,000 |

### Skill File Sizes

| File | ~Tokens | When Loaded |
|------|--------:|-------------|
| SKILL.md | ~918 | Always (skill trigger) |
| domain-routing.md | ~994 | Step 1: identify domain |
| recipes/stores.md (largest) | ~325 | Step 2: only if domain = stores |
| recipes/blog.md (smallest) | ~55 | Step 2: only if domain = blog |

### Scenario Comparison (with per-domain split)

| Scenario | Direct MCP | With Skill | Delta |
|----------|-----------|------------|-------|
| Stores recipe hit | ~3,950 tokens | ~4,237 tokens | +7% |
| Blog recipe hit | ~3,950 tokens | ~3,967 tokens | ~0% |
| BrowseMenu avoided (no URL) | ~30,795 tokens | ~2,662 tokens | **-91%** |
| BrowseMenu avoided (domain URL) | ~27,560 tokens | ~2,662 tokens | **-90%** |
| WixREADME fallback (rare) | ~3,950 tokens | ~5,612 tokens | +42% |

### Key Insight

The skill is nearly free for recipe-hit scenarios (+0-7%) while preventing
BrowseMenu catastrophes that waste 23,000-27,000 tokens. `SearchWixRESTDocumentation`
is **33x cheaper** than `BrowseWixRESTDocsMenu`.

### Estimate Token Savings from Log

```bash
awk -F'|' '{
  gsub(/^ +| +$/, "", $2)
  if ($2 == "RECIPE_HIT") saved -= 287
  if ($2 == "RECIPE_MISS") saved += 22860
  if ($2 == "BROWSE_AVOIDED") saved += 22860
  if ($2 == "README_FALLBACK") saved -= 1662
} END { printf "Estimated net tokens saved: %d\n", saved }' \
  ~/.claude/skills/wix-mcp/logs/wix-mcp.log
```

## Log Evaluation

The skill logs every decision to `~/.claude/skills/wix-mcp/logs/wix-mcp.log`.

### Log Format

```
YYYY-MM-DD HH:MM:SS | EVENT_TYPE | DOMAIN | DETAIL
```

### Event Types

| Event | Meaning | Token Impact |
|-------|---------|-------------|
| `RECIPE_HIT` | Recipe found in domain file | Near zero cost (+0-7%) |
| `RECIPE_MISS` | No recipe, used Search instead | Saved ~22K tokens (avoided BrowseMenu) |
| `README_FALLBACK` | Had to call WixREADME | Small overhead (+42%) |
| `BROWSE_AVOIDED` | Used Search instead of BrowseMenu | Saved ~22K tokens |
| `BROWSE_USED` | Had to use BrowseMenu (with deep URL) | Partial savings |

### Commands

```bash
# View all entries
cat ~/.claude/skills/wix-mcp/logs/wix-mcp.log

# View last 20 entries
tail -20 ~/.claude/skills/wix-mcp/logs/wix-mcp.log

# Count each event type
grep -c RECIPE_HIT ~/.claude/skills/wix-mcp/logs/wix-mcp.log
grep -c RECIPE_MISS ~/.claude/skills/wix-mcp/logs/wix-mcp.log
grep -c README_FALLBACK ~/.claude/skills/wix-mcp/logs/wix-mcp.log

# Summary with counts
awk -F'|' '{gsub(/^ +| +$/, "", $2); print $2}' \
  ~/.claude/skills/wix-mcp/logs/wix-mcp.log | sort | uniq -c | sort -rn

# Most queried domains
awk -F'|' '{gsub(/^ +| +$/, "", $3); print $3}' \
  ~/.claude/skills/wix-mcp/logs/wix-mcp.log | sort | uniq -c | sort -rn

# Find recurring fallback topics (signals stale recipes)
grep README_FALLBACK ~/.claude/skills/wix-mcp/logs/wix-mcp.log | \
  awk -F'|' '{print $3, $4}' | sort | uniq -c | sort -rn

# Reset the log
> ~/.claude/skills/wix-mcp/logs/wix-mcp.log
```

### Example Interpretation

```
$ awk -F'|' '{gsub(/^ +| +$/, "", $2); print $2}' logs/wix-mcp.log | sort | uniq -c | sort -rn
     15 RECIPE_HIT
      4 RECIPE_MISS
      1 README_FALLBACK
```

Out of 20 lookups: 15 (75%) served from local recipe files at near-zero
overhead. 4 used Search instead of BrowseMenu, saving ~91K tokens total.
Only 1 required the WixREADME fallback.

## Maintenance Guide

### When to Update

Update the recipe files when:
- The log shows frequent `README_FALLBACK` for a specific domain
- Wix announces new APIs or features
- You notice a recipe URL returning 404

### How to Update

**Automatic (recommended):**
```
/update-wix-recipes
```
This command calls WixREADME, compares the response with existing recipe files,
and updates any that have changed.

**Manual:**
Edit the relevant file in `~/.claude/skills/wix-mcp/recipes/`. Each file uses
the same table format:

```markdown
# <Domain> Recipes

| Recipe | Keywords | URL |
|--------|----------|-----|
| Recipe Name | keyword1, keyword2 | `https://dev.wix.com/docs/...` |
```

### What Triggers Staleness

Wix may add new recipes to the MCP at any time. Since the skill pre-indexes
the recipe catalog, new recipes won't be in the local files until updated.
The `WixREADME` fallback (Step 4 in the decision flow) catches these cases,
and the log tracks them so you know when to refresh.
