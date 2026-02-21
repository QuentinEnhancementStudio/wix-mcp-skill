# Wix MCP Documentation Navigator

A Claude Code skill that helps AI agents efficiently find Wix API documentation
through the Wix MCP tools, minimizing token usage and unnecessary API calls.

## What This Skill Does

When an agent needs Wix API information, the default MCP workflow calls
`WixREADME` (~1,950 tokens) then potentially `BrowseWixRESTDocsMenu` (107K+
characters / ~26,845 tokens). This skill short-circuits that by providing:

- **Inline recipe URLs** — 6 single-recipe domains have URLs directly in
  SKILL.md, enabling instant `ReadFullDocsArticle` with zero file reads
- **Per-domain recipe files** — 7 multi-recipe domains use recipe files with
  article clusters, Quick facts, and fallback search terms
- **Parallel execution patterns** — speculative search, cluster parallel reads,
  and multi-domain parallel patterns match or exceed raw MCP parallelism
- **Quick facts cache** — common API facts answer questions with 0 MCP calls

## Usage

- **Auto-invoked:** Claude loads the skill automatically when the task involves
  Wix API documentation
- **Manual:** Type `/wix-mcp` in Claude Code

## Architecture

```
SKILL.md (always loaded, ~1,400 tokens)
├── 6 inline recipe URLs (instant — 0 reads)
├── 7 multi-recipe domain routing (1 read each)
├── Domain intent-to-file mapping
└── Parallel execution patterns

recipes/<domain>.md (loaded on demand, 1 per query)
├── Article clusters (Keywords, Recipe URL, Related, Quick facts)
└── Fallback section (search terms + deep menu URL)
```

### Hot Path Comparison

| Path | File Reads | MCP Calls | Wall-clock |
|------|-----------|-----------|------------|
| Instant recipe (blog, media, etc.) | 0 | 1 | Fastest |
| Fact cache hit (stores V3 facts) | 1 | 0 | Fast |
| Recipe hit, no Related | 1 | 1 | Fast |
| Recipe hit + Related (parallel) | 1 | 2-6 parallel | Fast |
| Recipe miss (speculative search) | 1 | 1 (already running) | Fast |
| Recipe miss (no speculative) | 1 | 1+1 sequential | Medium |
| WixREADME fallback | 1 | 2-3 | Slow |

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
| SKILL.md (with inline routing) | ~1,400 | Always (skill trigger) |
| recipes/stores.md (largest) | ~700 | Only if domain = stores |
| recipes/blog.md (smallest) | ~80 | Never (inline in SKILL.md) |

### Scenario Comparison

| Scenario | Raw MCP | With Skill | Delta |
|----------|---------|------------|-------|
| Instant recipe (blog, media, etc.) | ~3,950 tokens | ~3,400 tokens | **-14%** (0 reads) |
| Fact cache hit | ~3,950 tokens | ~2,100 tokens | **-47%** (0 MCP) |
| Stores recipe hit (cluster parallel) | ~14,000+ (14 calls) | ~8,100 (3 parallel) | **-42%** |
| Stores recipe hit (speculative search) | ~3,950 tokens | ~5,250 tokens | +33% (search wasted) |
| BrowseMenu avoided (no URL) | ~30,795 tokens | ~2,150 tokens | **-93%** |
| BrowseMenu avoided (domain URL) | ~27,560 tokens | ~2,150 tokens | **-92%** |
| WixREADME fallback (rare) | ~3,950 tokens | ~5,612 tokens | +42% |

### Parallelism Comparison (wall-clock)

| Scenario | Raw MCP (turns) | With Skill (turns) |
|----------|-----------------|-------------------|
| Instant recipe | 1 (search) + 1 (read) = 2 | 1 (read directly) = **1** |
| Multi-recipe, recipe hit | 1 (search) + 1 (read) = 2 | 1 (file read) + 1 (MCP read) = 2 |
| Multi-recipe, speculative | 1 (search) + 1 (read) = 2 | 1 (file + search parallel) + 0-1 = **1-2** |
| Fact cache hit | 1 (search) + 1 (read) = 2 | 1 (file read) + 0 = **1** |
| Cluster parallel read | N sequential = N | 1 (file) + 1 (N parallel reads) = **2** |

### Experiment Results (Catalog V3 Compatibility Question)

| Agent | MCP Calls | Turns | Approach |
|-------|----------:|------:|----------|
| A (raw MCP, no skill) | 16 | 8+ | Sequential discovery |
| B (skill v1, flat recipes) | 14 | 7+ | Recipe hit, no Related articles |
| C (skill v2, clusters) | 0-3 | 1-2 | Fact cache or parallel cluster read |

### Estimate Token Savings from Log

```bash
awk -F'|' '{
  gsub(/^ +| +$/, "", $2)
  if ($2 == "RECIPE_HIT") saved -= 287
  if ($2 == "RECIPE_MISS") saved += 22860
  if ($2 == "BROWSE_AVOIDED") saved += 22860
  if ($2 == "README_FALLBACK") saved -= 1662
  if ($2 == "FACT_CACHE_HIT") saved += 3950
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
| `RECIPE_HIT` | Recipe found, read article(s) | Near zero cost |
| `RECIPE_MISS` | No recipe, used Search instead | Saved ~22K tokens |
| `README_FALLBACK` | Had to call WixREADME | Small overhead (+42%) |
| `BROWSE_AVOIDED` | Used Search instead of BrowseMenu | Saved ~22K tokens |
| `BROWSE_USED` | Had to use BrowseMenu (with deep URL) | Partial savings |
| `FACT_CACHE_HIT` | Answered from cached facts | Saved ~4K tokens (0 MCP) |

### Commands

```bash
# Summary with counts
awk -F'|' '{gsub(/^ +| +$/, "", $2); print $2}' \
  ~/.claude/skills/wix-mcp/logs/wix-mcp.log | sort | uniq -c | sort -rn

# Most queried domains
awk -F'|' '{gsub(/^ +| +$/, "", $3); print $3}' \
  ~/.claude/skills/wix-mcp/logs/wix-mcp.log | sort | uniq -c | sort -rn

# Fact cache hit rate
echo "Cache hits:"; grep -c FACT_CACHE_HIT ~/.claude/skills/wix-mcp/logs/wix-mcp.log
echo "Total hits:"; grep -c RECIPE_HIT ~/.claude/skills/wix-mcp/logs/wix-mcp.log

# Find recurring fallbacks (stale recipes)
grep README_FALLBACK ~/.claude/skills/wix-mcp/logs/wix-mcp.log | \
  awk -F'|' '{print $3, $4}' | sort | uniq -c | sort -rn

# Reset
> ~/.claude/skills/wix-mcp/logs/wix-mcp.log
```

## Maintenance Guide

### When to Update

- Log shows frequent `README_FALLBACK` for a domain
- Wix announces new APIs
- Recipe URL returns 404
- Quick facts outdated (verify against source article URLs)

### How to Update

**Automatic:** `/update-wix-recipes`

**Manual:** Edit recipe files in `~/.claude/skills/wix-mcp/recipes/`.
Format: article clusters with Keywords, Recipe URL, optional Related and
Quick facts, plus Fallback section with search terms.

For single-recipe domains, also update the inline URL in SKILL.md.
