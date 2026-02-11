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

1. **Identify the domain** from the user's intent (stores, bookings, blog, etc.)
2. **Load only that domain's recipe file** (~50-450 tokens instead of ~26,845)
3. **Call `ReadFullDocsArticle`** directly with the recipe URL
4. **Fall back** to `SearchWixRESTDocumentation` (33x cheaper than Browse) or `WixREADME` only when needed

### Results

| Scenario | Without Skill | With Skill | Savings |
|----------|------------:|----------:|---------:|
| Recipe hit (stores) | ~3,950 tokens | ~4,237 tokens | -7% overhead |
| Recipe hit (blog) | ~3,950 tokens | ~3,967 tokens | ~0% |
| BrowseMenu avoided | ~30,795 tokens | ~2,662 tokens | **91%** |

The skill is nearly free on recipe hits (+0-7%) while preventing BrowseMenu calls that waste 23,000-27,000 tokens.

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
} END { printf "Estimated net tokens saved: %d\n", saved }' \
  ~/.claude/skills/wix-mcp/logs/wix-mcp.log
```

## File Structure

```
skill/                          # -> ~/.claude/skills/wix-mcp/
├── SKILL.md                    # Core skill (auto-trigger rules + decision flow)
├── domain-routing.md           # Intent-to-domain mapping + search keywords
├── decision-tree.md            # Full tool selection flowchart
├── README.md                   # Internal benchmarks + maintenance guide
├── recipes/                    # Per-domain recipe indexes
│   ├── bookings.md             # 9 recipes
│   ├── stores.md               # 6 recipes
│   ├── cms.md                  # 5 recipes
│   ├── payments.md             # 3 recipes
│   ├── sites.md                # 3 recipes
│   ├── platform.md             # 3 recipes
│   ├── contacts.md             # 2 recipes
│   ├── blog.md                 # 1 recipe
│   ├── pricing-plans.md        # 1 recipe
│   ├── restaurants.md          # 1 recipe
│   ├── events.md               # 1 recipe
│   ├── media.md                # 1 recipe
│   └── rich-content.md         # 1 recipe
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
