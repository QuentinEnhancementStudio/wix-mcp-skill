# Tool Selection Decision Tree

Follow this top-down when looking for Wix API documentation.

## Entry Point

```
START
  |
  +-- User wants SDK/client-side docs?
  |   YES -> SearchWixSDKDocumentation(keywords)
  |           Return SDK docs to user
  |           STOP
  |
  +-- User wants headless/external app docs?
  |   YES -> SearchWixHeadlessDocumentation(keywords)
  |           Return headless docs to user
  |           STOP
  |
  +-- Identify domain from SKILL.md routing table (no file read needed)
  |
  +-- INSTANT RECIPE domain? (blog, media, events, restaurants, pricing-plans, rich-content)
  |   YES -> ReadFullDocsArticle(inline URL from SKILL.md) + log RECIPE_HIT
  |           ALL IN PARALLEL
  |           -> Return documentation to user
  |           DONE
  |
  +-- MULTI-RECIPE domain (stores, bookings, cms, payments, contacts, sites, platform)
  |   |
  |   +-- Read recipes/<domain>.md
  |   |   (OPTIONAL: speculative SearchWixRESTDocumentation in parallel — see Parallel Patterns)
  |   |
  |   +-- RECIPE FOUND
  |   |   |
  |   |   +-- Has "Quick facts" that fully answer the question?
  |   |   |   YES -> Log: FACT_CACHE_HIT <domain> "<recipe>"
  |   |   |         -> Return facts directly (zero MCP calls)
  |   |   |         DONE
  |   |   |
  |   |   +-- Has "Related" articles?
  |   |   |   YES -> ReadFullDocsArticle(recipe URL)
  |   |   |         + ReadFullDocsArticle(relevant Related URLs only)
  |   |   |         + log RECIPE_HIT
  |   |   |         ALL IN PARALLEL
  |   |   |         -> Return documentation to user
  |   |   |         DONE
  |   |   |
  |   |   +-- No "Related"
  |   |       -> ReadFullDocsArticle(recipe URL) + log RECIPE_HIT in parallel
  |   |       -> Return documentation to user
  |   |       DONE
  |   |
  |   +-- NO RECIPE FOUND
  |       -> If speculative search was running, use its results
  |       -> Otherwise: SearchWixRESTDocumentation(Fallback terms from recipe file)
  |       -> Log: RECIPE_MISS + BROWSE_AVOIDED
  |       |
  |       +-- Search found relevant article?
  |       |   YES -> ReadFullDocsArticle(article URL)
  |       |         -> Has code examples? Return to user. DONE
  |       |         -> No examples? ReadFullDocsMethodSchema(URL). DONE
  |       |
  |       +-- Nothing useful?
  |           -> Log: README_FALLBACK
  |           -> WixREADME() -> Follow instructions
  |           DONE
```

## Parallel Patterns

### Pattern 1: Instant recipe (fastest — 0 reads)
Domain is single-recipe (blog, media, events, restaurants, pricing-plans, rich-content).
URL is inline in SKILL.md. Fire `ReadFullDocsArticle` + `log.sh` immediately.
```
ReadFullDocsArticle(URL) + log.sh RECIPE_HIT  →  in parallel
```

### Pattern 2: Speculative search (same speed as raw MCP)
For multi-recipe domains, fire recipe file Read + SearchWixRESTDocumentation
in parallel. This ensures RECIPE_MISS has zero additional latency.
```
Read recipes/<domain>.md + SearchWixRESTDocumentation(keywords)  →  in parallel
  Recipe hit  → discard search, use recipe URL
  Recipe miss → search result already available
```
Trade-off: wastes ~750 tokens on recipe hits. Use when speed matters most.

### Pattern 3: Cluster parallel read
Recipe has Related articles. Fire all reads simultaneously.
```
ReadFullDocsArticle(recipe) + ReadFullDocsArticle(related1) + ReadFullDocsArticle(related2) + log.sh  →  all in parallel
```
Only include Related articles relevant to the specific question.

### Pattern 4: Multi-domain question
User's question spans two domains. Read both recipe files in parallel.
```
Read recipes/stores.md + Read recipes/bookings.md  →  in parallel
```

### Pattern 5: SDK + REST
User might need both SDK and REST docs.
```
SearchWixSDKDocumentation(kw) + SearchWixRESTDocumentation(kw)  →  in parallel
```

## Sequential Dependencies (cannot parallelize)

- `SearchWixRESTDocumentation` → `ReadFullDocsArticle` (need URL from search)
- `ReadFullDocsArticle` → `ReadFullDocsMethodSchema` (only if no examples found)

## Fact Cache Short-Circuit

When a recipe cluster includes `Quick facts`, check whether the facts directly
answer the user's question before making any MCP calls. Zero tokens from MCP.

Examples:
- "What package for V3 categories?" → `@wix/categories`
- "How to detect catalog version?" → `catalogVersioning.getCatalogVersion()`
- "Are V1 and V3 compatible?" → No, wrong version calls fail
