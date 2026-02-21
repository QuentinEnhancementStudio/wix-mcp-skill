---
name: wix-mcp
description: >
  Efficient navigator for Wix MCP documentation tools. Use this skill when an
  agent needs to find Wix API documentation, code examples, method schemas, or
  recipes covering stores, products, bookings, appointments, blog posts, CMS
  collections, events, pricing plans, restaurants, contacts, CRM, media uploads,
  payments, eCommerce, or any Wix platform API. Provides a pre-indexed recipe
  catalog and domain routing to minimize token usage and unnecessary MCP calls.
allowed-tools: Bash(~/.claude/skills/wix-mcp/scripts/log.sh *)
---

# Wix MCP Documentation Navigator

Pre-indexed recipe catalog with inline routing. Optimized for parallelism:
single-recipe domains need 0 file reads, multi-recipe domains need 1.

## Rules

1. **NEVER** call `BrowseWixRESTDocsMenu` without a deep `menuUrl` (107K+ chars)
2. **Quick facts first** — if facts fully answer the question, 0 MCP calls
3. **Selective Related** — only read Related articles relevant to the question
4. **Maximize parallelism** — use the parallel patterns below

## Domain Routing

Recipe base: `https://dev.wix.com/docs/picasso/wix-ai-docs/recipes-v2/manage`

### Instant recipes (0 file reads — call ReadFullDocsArticle directly)

| Keywords | URL (append to base) |
|----------|----------------------|
| blog, post, article, publish post | `/blog/recipe-how-to-create-blog-posts-rest` |
| upload image, media manager, import file | `/media/recipe-upload-media-to-wix` |
| event, ticket, RSVP, list events | `/events/recipe-list-events` |
| restaurant, menu, food, dishes | `/restaurants/recipe-wix-restaurants-setup` |
| pricing plan, subscription, membership | `/pricing-plans/recipe-create-and-update-pricing-plans` |
| ricos, rich content, html to ricos | `/rich-content/recipe-ricos-converter-service` |

Call `ReadFullDocsArticle(base + path)` immediately — no file read needed.
If question doesn't match, read recipe file for fallback search terms.

### Multi-recipe domains (1 file read)

| Keywords | Recipe file |
|----------|-------------|
| products, catalog, store, shop, cart, checkout, order, ecommerce | `stores` |
| appointment, booking, staff, schedule, hours, class, course | `bookings` |
| collection, data, CMS, database, items | `cms` |
| payment, invoice, charge, link, credit card | `payments` |
| contact, lead, CRM, customer, label | `contacts` |
| site, create site, domain, currency, timezone | `sites` |
| install app, velo, wix code | `platform` |

Read `~/.claude/skills/wix-mcp/recipes/<name>.md` to find the matching recipe.

### SDK or Headless?
- SDK/client-side → `SearchWixSDKDocumentation(keywords)` → DONE
- Headless/external → `SearchWixHeadlessDocumentation(keywords)` → DONE

## Decision Flow

### Instant recipe domain
`ReadFullDocsArticle(base + path)` + `log.sh RECIPE_HIT` — in parallel. DONE.

### Multi-recipe domain
1. Read recipe file (OPTIONAL: + speculative `SearchWixRESTDocumentation` in parallel)
2. Quick facts answer fully? → Return facts, log `FACT_CACHE_HIT`, DONE
3. Recipe found + Related → `ReadFullDocsArticle(recipe + relevant Related)` IN PARALLEL, log `RECIPE_HIT`, DONE
4. Recipe found, no Related → `ReadFullDocsArticle(recipe URL)` + log — parallel, DONE
5. No recipe → use speculative search result if available, or `SearchWixRESTDocumentation(Fallback terms)`, log `RECIPE_MISS`
   → Found article? → `ReadFullDocsArticle(URL)`, DONE
   → Nothing? → `WixREADME()`, log `README_FALLBACK`, DONE

## Parallel Patterns

### Pattern 1: Instant recipe (fastest — 1 turn, 0 reads)
```
ReadFullDocsArticle(inline URL) + log.sh RECIPE_HIT  →  parallel
```

### Pattern 2: Speculative search (matches raw MCP speed)
For multi-recipe domains, fire recipe file Read + SearchWixRESTDocumentation
in parallel. RECIPE_MISS has zero additional latency.
```
Read recipes/<domain>.md + SearchWixRESTDocumentation(keywords)  →  parallel
  Recipe hit  → discard search, use recipe URL
  Recipe miss → search result already available, no wait
```
Trade-off: wastes ~750 tokens on recipe hits. Use when speed > token savings.

### Pattern 3: Cluster parallel read
Recipe has Related articles. Fire all reads simultaneously.
```
ReadFullDocsArticle(recipe) + ReadFullDocsArticle(related1) + ReadFullDocsArticle(related2) + log.sh  →  all parallel
```
Only include Related articles relevant to the specific question.

### Pattern 4: Multi-domain or SDK+REST
```
Read recipes/stores.md + Read recipes/bookings.md  →  parallel
SearchWixSDKDocumentation(kw) + SearchWixRESTDocumentation(kw)  →  parallel
```

### Sequential only
- `SearchWixRESTDocumentation` → `ReadFullDocsArticle` (need URL)
- `ReadFullDocsArticle` → `ReadFullDocsMethodSchema` (only if no examples)

## Tool Quick Reference

| Situation | Use | Avoid |
|-----------|-----|-------|
| Quick facts answer question | Return facts (0 MCP) | ReadFullDocsArticle |
| Instant recipe domain | ReadFullDocsArticle (inline URL) | Recipe file read |
| Recipe + Related | ReadFullDocsArticle x N parallel | Sequential reads |
| Recipe, no Related | ReadFullDocsArticle (recipe URL) | WixREADME |
| No recipe | SearchWixRESTDocumentation | BrowseWixRESTDocsMenu |
| No examples, need schema | ReadFullDocsMethodSchema | BrowseWixRESTDocsMenu |
| SDK docs | SearchWixSDKDocumentation | SearchWixRESTDocumentation |
| Headless docs | SearchWixHeadlessDocumentation | |

## Logging

```bash
~/.claude/skills/wix-mcp/scripts/log.sh <EVENT> <DOMAIN> "<DETAIL>"
```
Always run log calls in parallel with MCP reads — they are independent.

Events: `RECIPE_HIT`, `RECIPE_MISS`, `FACT_CACHE_HIT`, `README_FALLBACK`,
`BROWSE_AVOIDED`, `BROWSE_USED`

## Maintenance

Run `/update-wix-recipes` when log shows frequent `README_FALLBACK` events.
For single-recipe domains, also update inline URLs in this file.

## Reference Files (rarely needed)

- [recipes/](recipes/) — Per-domain recipe files (1 per query max)
- [domain-routing.md](domain-routing.md) — Deep menu URLs (last resort only)
- [decision-tree.md](decision-tree.md) — Detailed decision flowchart
- [README.md](README.md) — Benchmarks, log evaluation, maintenance
