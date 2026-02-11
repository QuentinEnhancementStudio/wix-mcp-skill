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

This skill provides a pre-indexed recipe catalog split by domain and routing
intelligence so agents can find the right Wix API documentation with minimal
token usage. Only the relevant domain's recipes are loaded, not all 37.

## Critical Rules

1. **Check the domain recipe file FIRST** before calling any Wix MCP
   documentation tool. Identify the domain, then read only that domain's
   recipe file from [recipes/](recipes/).

2. **NEVER call `BrowseWixRESTDocsMenu` without a deep `menuUrl`.**
   Top-level calls return 107K+ characters. Use `SearchWixRESTDocumentation`
   instead. Deep menu URLs are listed in [domain-routing.md](domain-routing.md)
   as a last resort only.

3. **Fall back to `WixREADME` only when** no recipe matches in the domain file
   AND `SearchWixRESTDocumentation` doesn't return useful results.

## Decision Flow

Follow [decision-tree.md](decision-tree.md) for the full logic. Summary:

### Step 1: Identify the domain
Map the request to a domain using [domain-routing.md](domain-routing.md).

### Step 2: Load ONLY that domain's recipe file
Read the matching file from `recipes/`:

- [recipes/bookings.md](recipes/bookings.md) — Bookings (9 recipes)
- [recipes/stores.md](recipes/stores.md) — Stores (6 recipes)
- [recipes/payments.md](recipes/payments.md) — Payments (3 recipes)
- [recipes/cms.md](recipes/cms.md) — CMS (5 recipes)
- [recipes/contacts.md](recipes/contacts.md) — Contacts (2 recipes)
- [recipes/sites.md](recipes/sites.md) — Sites (3 recipes)
- [recipes/platform.md](recipes/platform.md) — Platform (3 recipes)
- [recipes/blog.md](recipes/blog.md) — Blog (1 recipe)
- [recipes/pricing-plans.md](recipes/pricing-plans.md) — Pricing Plans (1 recipe)
- [recipes/restaurants.md](recipes/restaurants.md) — Restaurants (1 recipe)
- [recipes/events.md](recipes/events.md) — Events (1 recipe)
- [recipes/media.md](recipes/media.md) — Media (1 recipe)
- [recipes/rich-content.md](recipes/rich-content.md) — Rich Content (1 recipe)

If a recipe matches:
```
-> Log: ~/.claude/skills/wix-mcp/scripts/log.sh RECIPE_HIT <domain> "<recipe>"
-> ReadFullDocsArticle(articleUrl: "<recipe URL>")
-> Return the documentation and examples to the user
```

### Step 3: No recipe — use Search
```
-> Log: ~/.claude/skills/wix-mcp/scripts/log.sh RECIPE_MISS <domain> "<intent>"
-> SearchWixRESTDocumentation(searchTerm, maxResults: 5)
-> Use search terms from domain-routing.md
```

### Step 4: Search found nothing — WixREADME fallback
```
-> Log: ~/.claude/skills/wix-mcp/scripts/log.sh README_FALLBACK <domain> "<intent>"
-> WixREADME()
-> Follow its instructions to find relevant docs
```

### Step 5: Read article and return info
```
-> ReadFullDocsArticle(article URL)
-> Has code examples? -> Return examples to the user
-> No examples? -> ReadFullDocsMethodSchema for full schema -> Return to user
```

## Tool Selection Quick Reference

| Task | Use | Avoid |
|------|-----|-------|
| Recipe exists for topic | `ReadFullDocsArticle` (recipe URL) | `WixREADME` |
| No recipe, find API docs | `SearchWixRESTDocumentation` | `BrowseWixRESTDocsMenu` |
| Need code examples | `ReadFullDocsArticle` | `ReadFullDocsMethodSchema` |
| No examples, need schema | `ReadFullDocsMethodSchema` | `BrowseWixRESTDocsMenu` |
| User wants SDK docs | `SearchWixSDKDocumentation` | `SearchWixRESTDocumentation` |
| User wants headless docs | `SearchWixHeadlessDocumentation` | |

## Logging

After every decision point, log the outcome:

```bash
~/.claude/skills/wix-mcp/scripts/log.sh <EVENT_TYPE> <DOMAIN> "<DETAIL>"
```

Event types: `RECIPE_HIT`, `RECIPE_MISS`, `README_FALLBACK`, `BROWSE_AVOIDED`,
`BROWSE_USED`

## Maintenance

Run `/update-wix-recipes` to refresh recipes from WixREADME when the log shows
frequent `README_FALLBACK` events. See [README.md](README.md) for details.

## Reference Files

- [recipes/](recipes/) — Per-domain recipe files (load only the one you need)
- [domain-routing.md](domain-routing.md) — Intent mapping, search terms, menu URLs
- [decision-tree.md](decision-tree.md) — Full decision logic
- [README.md](README.md) — Performance benchmarks, log evaluation, maintenance guide
