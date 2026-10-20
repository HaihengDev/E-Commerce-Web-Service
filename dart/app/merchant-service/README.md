# Merchant service

Run from this directory with `dart_frog dev`. The API listens on port 8002 by
default. Configure `PRODUCT_SERVICE_URL` (default `http://localhost:8000`) and
`CATEGORY_SERVICE_URL` (default `http://localhost:8001/categories`) to connect
to the existing services.

The merchant API forwards requests to the product and category services:

- `GET|POST /products`
- `GET|PUT|PATCH|DELETE /products/:id`
- `GET|POST /categories`
- `GET|PUT|DELETE /categories/:id`

Product creation accepts a category ID and the product service checks that the
category exists. Include `merchant_name` with every product create request; the
product API returns it so a storefront can show who is responsible for the
product. Category deletion checks the product list first and returns `409
Conflict` when products still reference that category.
