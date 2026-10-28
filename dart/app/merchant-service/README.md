# Merchant service

Run from this directory with `dart_frog dev`. The API listens on port 8002 by
default. Configure `PRODUCT_SERVICE_URL` (default `http://localhost:8000`) and
`CATEGORY_SERVICE_URL` (default `http://localhost:8001/categories`) to connect
to the existing services.

Configure `AUTH_SERVICE_URL` (default `http://localhost:8003`) and
`ORDER_SERVICE_URL` (default `http://localhost:8004`) to connect to the
authentication and order services. Set `JWT_SECRET` to the same value used by
those services.

The merchant API forwards requests to the product and category services:

- `GET|POST /products`
- `GET|PUT|PATCH|DELETE /products/:id`
- `GET|POST /categories`
- `GET|PUT|DELETE /categories/:id`
- `POST /auth/register` and `POST /auth/login`
- `GET|POST /orders`

Product creation accepts a category ID and the product service checks that the
category exists. The product API derives the product's merchant name from the
verified account token so clients cannot claim another merchant's identity.
Category deletion checks the product list first and returns `409
Conflict` when products still reference that category.

Product creation and management require a merchant bearer token. Order access
requires a normal user bearer token. Include `Authorization: Bearer <token>`.

The gateway caches successful GET responses in Redis and advances its cache
version after successful writes. Start the shared Redis instance from the
repository root with `docker compose up -d redis`. Set `REDIS_URL` (default
`redis://localhost:6379`) and optionally `REDIS_CACHE_TTL_SECONDS` (default
60). Redis is best-effort and the gateway continues forwarding requests if it
is unavailable.
