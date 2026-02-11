# Domain Routing Table

Maps user intents to Wix domains. Use this to identify which recipe file to
load from `recipes/` and what search terms to use if no recipe matches.

## Intent-to-Domain Mapping

| User Says / Wants | Domain | Recipe File |
|----|--------|-------------|
| products, catalog, inventory, store, shop | Stores | [recipes/stores.md](recipes/stores.md) |
| cart, checkout, order, purchase, ecommerce | eCommerce | [recipes/stores.md](recipes/stores.md) |
| appointment, class, course, service, booking | Bookings | [recipes/bookings.md](recipes/bookings.md) |
| staff, employee, schedule, hours, availability | Bookings | [recipes/bookings.md](recipes/bookings.md) |
| blog, post, article, publish, write | Blog | [recipes/blog.md](recipes/blog.md) |
| menu, dish, food, restaurant, ordering | Restaurants | [recipes/restaurants.md](recipes/restaurants.md) |
| event, ticket, RSVP, registration | Events | [recipes/events.md](recipes/events.md) |
| plan, subscription, membership, pricing | Pricing Plans | [recipes/pricing-plans.md](recipes/pricing-plans.md) |
| payment, pay, invoice, charge, link | Payments | [recipes/payments.md](recipes/payments.md) |
| contact, lead, CRM, customer, label | Contacts | [recipes/contacts.md](recipes/contacts.md) |
| collection, data, items, CMS, database | CMS | [recipes/cms.md](recipes/cms.md) |
| site, create site, publish, domain | Sites | [recipes/sites.md](recipes/sites.md) |
| image, file, upload, media, photo | Media | [recipes/media.md](recipes/media.md) |
| rich content, ricos, HTML convert | Rich Content | [recipes/rich-content.md](recipes/rich-content.md) |
| install app, enable velo, wix code | Platform | [recipes/platform.md](recipes/platform.md) |
| currency, site properties, locale, timezone | Sites | [recipes/sites.md](recipes/sites.md) |

## Search Keywords by Domain

When no recipe matches, use these terms with
`SearchWixRESTDocumentation(searchTerm, maxResults: 5)`:

| Domain | Effective Search Terms |
|--------|----------------------|
| Stores | "catalog v3 products", "stores inventory", "product variant" |
| eCommerce | "ecommerce checkout", "cart", "ecommerce order" |
| Bookings | "bookings service", "booking availability", "booking slot" |
| Blog | "blog post create", "blog category" |
| Restaurants | "restaurant menu", "restaurant order" |
| Events | "events query", "event registration" |
| Pricing Plans | "pricing plans create", "pricing plan order" |
| Payments | "payment link", "wix payments setup" |
| Contacts/CRM | "contacts query", "contact label", "CRM" |
| CMS | "data items query", "data collection", "wix data" |
| Sites | "site properties", "create site" |
| Media | "media manager import", "upload file media" |
| Rich Content | "ricos convert", "rich content" |
| Platform | "app installer", "install app site" |
| Members | "members query", "member badge" |
| Notifications | "notifications send", "notification preferences" |

## Deep Menu URLs — LAST RESORT ONLY

If you must use `BrowseWixRESTDocsMenu`, ALWAYS pass one of these deep URLs.
NEVER call it without a `menuUrl` (returns 107K chars).

Even domain-level URLs return large responses. **Prefer SearchWixRESTDocumentation.**

| Domain | Menu URL |
|--------|----------|
| Stores | `https://dev.wix.com/docs/api-reference/business-solutions/stores` |
| Bookings | `https://dev.wix.com/docs/api-reference/business-solutions/bookings` |
| CMS | `https://dev.wix.com/docs/api-reference/business-solutions/cms` |
| CRM | `https://dev.wix.com/docs/api-reference/crm` |
| eCommerce | `https://dev.wix.com/docs/api-reference/business-solutions/e-commerce` |
| Events | `https://dev.wix.com/docs/api-reference/business-solutions/events` |
| Blog | `https://dev.wix.com/docs/api-reference/business-solutions/blog` |
| Pricing Plans | `https://dev.wix.com/docs/api-reference/business-solutions/pricing-plans` |
| Restaurants | `https://dev.wix.com/docs/api-reference/business-solutions/restaurants` |
| Media | `https://dev.wix.com/docs/api-reference/assets/media` |
| Site Properties | `https://dev.wix.com/docs/api-reference/business-management/site-properties` |
| Members | `https://dev.wix.com/docs/api-reference/crm/members` |
| Notifications | `https://dev.wix.com/docs/api-reference/crm/notifications` |
