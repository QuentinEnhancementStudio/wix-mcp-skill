# Stores Recipes

### Setup Online Store (Catalog V3)
**Keywords**: setup store, catalog, initialize store, new store, catalog v3, collections, categories, migration, versioning
**Recipe**: `https://dev.wix.com/docs/picasso/wix-ai-docs/recipes-v2/manage/stores/recipe-setup-online-store-catalog-v3`
**Related** (read in parallel):
- V1→V3 Migration Guide: `https://dev.wix.com/docs/api-reference/business-solutions/stores/catalog-v3/catalog-v1-to-v3-migration-guide`
- Categories API Intro: `https://dev.wix.com/docs/api-reference/business-solutions/stores/catalog-v3/categories/introduction`
- Catalog Versioning Intro: `https://dev.wix.com/docs/api-reference/business-solutions/stores/catalog-versioning/introduction`
- Catalog V3 Intro: `https://dev.wix.com/docs/api-reference/business-solutions/stores/catalog-v3/introduction`
- Wix Stores Overview: `https://dev.wix.com/docs/api-reference/business-solutions/stores/introduction`
**Quick facts**:
- V3 replaces `collections` with `categories` (separate package: `@wix/categories`)
- Field mapping: `collectionIds[i]` → `directCategories[i].id`
- V3 products: `productsV3.queryProducts()` (not `products.queryProducts()`)
- V1 and V3 are NOT backward compatible — wrong version calls fail silently or error
- Detect version: `catalogVersioning.getCatalogVersion()` from `@wix/stores`
- Categories API requires `treeReference: { appNamespace: "@wix/stores" }`
- V3 is default for new stores created after 2024

### Add Store Pages to Site
**Keywords**: store pages, cart page, checkout page, missing pages
**Recipe**: `https://dev.wix.com/docs/picasso/wix-ai-docs/recipes-v2/manage/stores/recipe-add-store-pages-to-site`

### Bulk Create Products with Options
**Keywords**: bulk products, multiple products, import products
**Recipe**: `https://dev.wix.com/docs/picasso/wix-ai-docs/recipes-v2/manage/stores/recipe-bulk-create-products-with-options`
**Related** (read in parallel):
- Catalog V1 Products Intro: `https://dev.wix.com/docs/api-reference/business-solutions/stores/catalog/products/introduction`
- Catalog V3 Products Intro: `https://dev.wix.com/docs/api-reference/business-solutions/stores/catalog-v3/products/introduction`

### Create Product with Options
**Keywords**: create product, product options, variants, sizes, colors
**Recipe**: `https://dev.wix.com/docs/picasso/wix-ai-docs/recipes-v2/manage/stores/recipe-create-product-with-options`
**Related** (read in parallel):
- Catalog V1 Products Intro: `https://dev.wix.com/docs/api-reference/business-solutions/stores/catalog/products/introduction`
- Catalog V3 Products Intro: `https://dev.wix.com/docs/api-reference/business-solutions/stores/catalog-v3/products/introduction`

### Update Product Pre-Order
**Keywords**: pre-order, preorder, backorder
**Recipe**: `https://dev.wix.com/docs/picasso/wix-ai-docs/recipes-v2/manage/stores/recipe-update-product-pre-order`

### Update Product with Options
**Keywords**: update product, modify product, change options, edit product
**Recipe**: `https://dev.wix.com/docs/picasso/wix-ai-docs/recipes-v2/manage/stores/recipe-update-product-with-options`
**Related** (read in parallel):
- Catalog V1 Products Intro: `https://dev.wix.com/docs/api-reference/business-solutions/stores/catalog/products/introduction`
- Catalog V3 Products Intro: `https://dev.wix.com/docs/api-reference/business-solutions/stores/catalog-v3/products/introduction`

## Fallback
**Search**: "catalog v3 products", "stores inventory", "product variant"
**Menu**: `https://dev.wix.com/docs/api-reference/business-solutions/stores`
