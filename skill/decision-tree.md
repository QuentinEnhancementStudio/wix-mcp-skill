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
  +-- Identify domain -> domain-routing.md
  |
  +-- Load ONLY that domain's recipe file -> recipes/<domain>.md
  |   |
  |   +-- RECIPE FOUND
  |   |   -> Log: RECIPE_HIT <domain> "<recipe name>"
  |   |   -> ReadFullDocsArticle(recipe URL)
  |   |   -> Return documentation and examples to user
  |   |   DONE
  |   |
  |   +-- NO RECIPE FOUND
  |       -> Log: RECIPE_MISS <domain> "<user intent>"
  |       -> SearchWixRESTDocumentation(keywords from domain-routing.md, maxResults: 5)
  |       -> Log: BROWSE_AVOIDED <domain> "Used Search instead"
  |       |
  |       +-- Search found relevant article?
  |       |   YES -> ReadFullDocsArticle(article URL)
  |       |         |
  |       |         +-- Has code examples?
  |       |         |   YES -> Return examples to user
  |       |         |         DONE
  |       |         |
  |       |         +-- No code examples?
  |       |             -> ReadFullDocsMethodSchema(article URL)
  |       |             -> Return schema info to user
  |       |             DONE
  |       |
  |       +-- Search found nothing useful?
  |           -> Log: README_FALLBACK <domain> "<user intent>"
  |           -> WixREADME (fallback for new/unknown recipes)
  |           -> Follow WixREADME instructions to find docs
  |           DONE
```

## Parallel Call Opportunities

These calls are independent and CAN run in parallel:
- Multiple `SearchWixRESTDocumentation` for different domains
- `SearchWixSDKDocumentation` + `SearchWixRESTDocumentation` (if user needs both)

These MUST be sequential (output needed as input):
- `domain-routing.md` -> then `recipes/<domain>.md` (need domain first)
- `SearchWixRESTDocumentation` -> then `ReadFullDocsArticle`
- `ReadFullDocsArticle` -> then `ReadFullDocsMethodSchema` (only if no examples)
