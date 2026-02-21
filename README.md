# Wix MCP Skill for Claude Code

A [Claude Code](https://docs.anthropic.com/en/docs/claude-code) skill that helps AI agents efficiently navigate [Wix MCP](https://dev.wix.com/docs/build-apps/developer-tools/frameworks-and-connected-services/mcp) documentation tools, minimizing token usage and unnecessary API calls.

## The Problem

When an agent needs Wix API information through the MCP, the default workflow is expensive:

| Tool Call | Response Size |
|-----------|------------:|
| `WixREADME()` | ~1,950 tokens |
| `BrowseWixRESTDocsMenu()` (no URL) | **~26,845 tokens** |
| `BrowseWixRESTDocsMenu()` (domain URL) | **~23,610 tokens** |
| `SearchWixRESTDocumentation()` | ~750 tokens |

A single `BrowseWixRESTDocsMenu` call without a deep URL dumps **107K+ characters** into context. Most of it is irrelevant to the query.

## The Solution

This skill pre-indexes all 37 Wix MCP recipes across 13 domains and routes agents to the right documentation with minimal token cost:

1. **Inline routing** — Domain-to-recipe mapping is in SKILL.md itself (no extra file read)
2. **Instant recipes** — 6 single-recipe domains have URLs inline, enabling immediate `ReadFullDocsArticle` with 0 file reads
3. **Article clusters** — Multi-recipe domains bundle Related articles for parallel reading, eliminating sequential discovery calls
4. **Quick facts cache** — Common API facts (package names, field mappings, version detection) answer questions with 0 MCP calls
5. **Parallel execution patterns** — Speculative search, cluster reads, and multi-domain patterns match or exceed raw MCP parallelism
6. **Fallback search terms** — Each recipe file includes optimized search terms for the RECIPE_MISS path, so `domain-routing.md` is rarely needed

### Measured Results (A/B Test: Catalog V3 Compatibility Question)

| Agent | MCP Calls | Total Tokens | Duration | Approach |
|-------|----------:|-------------:|---------:|----------|
| **Raw MCP (no skill)** | 12 | 64,505 | 84s | Sequential discovery, 3x BrowseMenu |
| **With skill v2** | 3 | 39,754 | 50s | Quick facts + parallel cluster read |

| Metric | Improvement |
|--------|------------|
| MCP calls | **-75%** (12 → 3) |
| Total tokens | **-38%** (64K → 40K) |
| Wall-clock time | **-40%** (84s → 50s) |
| BrowseMenu calls | **-100%** (3 → 0) |

### Scenario Comparison

| Scenario | Without Skill | With Skill | Delta |
|----------|------------:|----------:|---------:|
| Instant recipe (blog, media, etc.) | ~3,950 tokens | ~3,400 tokens | **-14%** |
| Fact cache hit (V3 questions) | ~3,950 tokens | ~2,100 tokens | **-47%** |
| Recipe hit + cluster parallel | ~14,000+ tokens | ~8,100 tokens | **-42%** |
| BrowseMenu avoided | ~30,795 tokens | ~2,150 tokens | **-93%** |

## Installation

### Quick Install

```bash
# Clone the repo
git clone https://github.com/QuentinEnhancementStudio/wix-mcp-skill.git /tmp/wix-mcp-skill

# Run the install script
/tmp/wix-mcp-skill/install.sh
```

### Manual Install

```bash
# 1. Copy the skill
mkdir -p ~/.claude/skills/wix-mcp
cp -r skill/ ~/.claude/skills/wix-mcp/

# 2. Copy the update command
mkdir -p ~/.claude/commands
cp commands/update-wix-recipes.md ~/.claude/commands/

# 3. Make log script executable
chmod +x ~/.claude/skills/wix-mcp/scripts/log.sh
```

### Verify Installation

Open Claude Code and type `/wix-mcp` — if it appears as a skill option, the installation worked.

## Usage

The skill **auto-triggers** when Claude detects a Wix API documentation query. You can also invoke it manually with `/wix-mcp`.

### Keeping Recipes Up to Date

Run `/update-wix-recipes` in Claude Code to refresh the recipe index from the Wix MCP. Do this when:
- The log shows frequent `README_FALLBACK` events
- Wix announces new APIs or features

### Monitoring Effectiveness

The skill logs every decision to `~/.claude/skills/wix-mcp/logs/wix-mcp.log`:

```bash
# Summary of event types
awk -F'|' '{gsub(/^ +| +$/, "", $2); print $2}' \
  ~/.claude/skills/wix-mcp/logs/wix-mcp.log | sort | uniq -c | sort -rn

# Estimate net token savings
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

## File Structure

```
skill/                          # -> ~/.claude/skills/wix-mcp/
├── SKILL.md                    # Core skill (inline routing + decision flow + parallel patterns)
├── domain-routing.md           # Deep menu URLs reference (rarely needed)
├── decision-tree.md            # Full tool selection flowchart with parallel patterns
├── README.md                   # Internal benchmarks + maintenance guide
├── recipes/                    # Per-domain recipe indexes (article cluster format)
│   ├── bookings.md             # 9 recipes (2 with Related cross-links)
│   ├── stores.md               # 6 recipes (4 with Related, 1 with Quick facts)
│   ├── cms.md                  # 5 recipes (1 with Related)
│   ├── payments.md             # 3 recipes (1 with Related)
│   ├── sites.md                # 3 recipes
│   ├── platform.md             # 3 recipes
│   ├── contacts.md             # 2 recipes
│   ├── blog.md                 # 1 recipe (instant — URL inline in SKILL.md)
│   ├── pricing-plans.md        # 1 recipe (instant — URL inline in SKILL.md)
│   ├── restaurants.md          # 1 recipe (instant — URL inline in SKILL.md)
│   ├── events.md               # 1 recipe (instant — URL inline in SKILL.md)
│   ├── media.md                # 1 recipe (instant — URL inline in SKILL.md)
│   └── rich-content.md         # 1 recipe (instant — URL inline in SKILL.md)
├── scripts/
│   └── log.sh                  # Decision logger
└── logs/                       # Created on first use

commands/                       # -> ~/.claude/commands/
└── update-wix-recipes.md       # /update-wix-recipes command
```

## Prerequisites

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) installed
- [Wix MCP](https://dev.wix.com/docs/build-apps/developer-tools/frameworks-and-connected-services/mcp) connected in Claude Code

## License

MIT
