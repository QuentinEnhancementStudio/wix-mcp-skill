---
description: Refresh the wix-mcp skill recipe index by fetching fresh data from WixREADME
---

Update the Wix MCP skill recipe files with current data from the Wix MCP.

## Steps

1. Call `WixREADME()` to get the current recipe index from Wix.

2. Parse the response and extract each domain section (Bookings, Stores, Payments,
   Restaurants, Blog, Pricing Plans, Contacts, CMS, Sites, Events, Platform,
   Media, Rich Content).

3. For each domain, compare the recipes in the WixREADME response with the
   existing file at `~/.claude/skills/wix-mcp/recipes/<domain>.md`.
   Domain-to-filename mapping:
   - Bookings -> recipes/bookings.md
   - Stores -> recipes/stores.md
   - Payments -> recipes/payments.md
   - Restaurants -> recipes/restaurants.md
   - Blog -> recipes/blog.md
   - Pricing Plans -> recipes/pricing-plans.md
   - Contacts -> recipes/contacts.md
   - CMS -> recipes/cms.md
   - Sites -> recipes/sites.md
   - Events -> recipes/events.md
   - Platform -> recipes/platform.md
   - Media -> recipes/media.md
   - Rich Content -> recipes/rich-content.md

4. For each file that differs or is missing, update it using this format:
   ```markdown
   # <Domain> Recipes

   | Recipe | Keywords | URL |
   |--------|----------|-----|
   | <Recipe Name> | <keyword1>, <keyword2>, ... | `<article URL>` |
   ```
   Generate 3-5 relevant keywords per recipe based on its name and description.

5. If WixREADME returns recipes for a domain that has no file, create the new file
   and add a corresponding entry to `domain-routing.md`.

6. Report a summary to the user:
   - Which files were updated (and what changed)
   - Which files were already up-to-date
   - Any new domains added
   - Total recipe count before and after

7. Log the update:
   ```bash
   ~/.claude/skills/wix-mcp/scripts/log.sh UPDATE recipes "<summary>"
   ```
