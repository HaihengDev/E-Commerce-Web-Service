# E-commerce services

This repository contains separate Dart Frog services and a public API gateway.
For local development, the services run on your host and MongoDB and Redis run
in Docker. This keeps `localhost` database URLs in `.env` valid.

## Deploy the whole application as one Render Docker service

The root `Dockerfile` builds all seven Dart Frog applications into one image.
Its entrypoint starts the six backend services on ports 8081–8086 and the API
gateway on Render's `PORT` (10000 by default). Only the gateway is exposed to
the internet; the app services call one another over loopback. MongoDB and
Redis remain external managed services.

In Render, create one **Web Service** connected to this repository and branch:

1. Select **Docker** as the runtime and set the Dockerfile path to `./Dockerfile`.
2. Leave Docker Command blank so Render runs the Dockerfile entrypoint.
3. Add the environment variables below. Use production database/Redis URLs;
   local Compose hostnames such as `mongo` and `redis` are not reachable on
   Render. Do not add a `PORT` override unless you also configure the service's
   exposed port to match it; Render supplies `PORT` for the gateway.
4. Deploy. The public Render URL serves the API gateway. Enable **Auto-Deploy
   On Commit** for the connected branch. Future updates deploy when you push:

   ```sh
   git add .
   git commit -m "Describe the change"
   git push origin main
   ```

Required runtime variables:

| Variable | Value |
| --- | --- |
| `MONGO_URI_AUTH_SERVICE` | Mongo connection string ending in `/ecommerce_auth` |
| `MONGO_URI_CATEGORY_SERVICE` | Mongo connection string ending in `/ecommerce_categories` |
| `MONGO_URI_PRODUCT_SERVICE` | Mongo connection string ending in `/ecommerce_products` |
| `MONGO_URI_ORDER_SERVICE` | Mongo connection string ending in `/ecommerce_orders` (used by order and payment services) |
| `REDIS_URL` | Hosted Redis connection string, including TLS/auth options required by your provider |
| `JWT_SECRET` | A private random value of at least 32 characters; use the same value for every service |
| `INTERNAL_SERVICE_TOKEN` | A different private random value of at least 32 characters |

The image sets internal service URLs to loopback addresses automatically. You
can leave `AUTH_SERVICE_URL`, `CATEGORY_SERVICE_URL`, `MERCHANT_SERVICE_URL`,
`ORDER_SERVICE_URL`, `PAYMENT_SERVICE_URL`, and `PRODUCT_SERVICE_URL` unset.
Set Stripe or PayPal credentials if enabling real payments. Keep
`PAYMENT_DEMO_MODE` off outside local demos.

This is a single deployment unit: a crash in any service restarts the whole
container, and all seven app processes scale together. Database data stays in
the external database services.

## Start local dependencies

On a fresh checkout, copy `.env.example` to `.env` and replace `JWT_SECRET` and
`INTERNAL_SERVICE_TOKEN` with separate random secrets of at least 32 characters.
Your existing local `.env` already has generated values; do not commit it.

From the repository root:

```sh
docker compose up -d mongo redis
```

MongoDB is published on `localhost:27017`, and Redis is published on
`localhost:6379`. Data persists in the `mongo-data` and `redis-data` Docker
volumes.

## Run the full stack with Docker

The Compose file can run MongoDB, Redis, all six Dart services, and the API
gateway. Make sure `.env` exists in the repository root (copy `.env.example` if
needed, then set the required secrets), then run:

```sh
docker compose up --build
```

The gateway is available at `http://localhost:8080`. The individual services
are also published on ports 8081 through 8086. Compose configures service URLs
and database connections to use container names, so these containers do not
use the host-only URLs in `.env` for internal communication. Provider settings
such as `STRIPE_SECRET_KEY` and `STRIPE_WEBHOOK_SECRET` are still read from
`.env`.

Stop the stack with `Ctrl+C`, or run `docker compose down` in another terminal.
The MongoDB and Redis data volumes are preserved when the stack stops. To follow
logs later, run `docker compose logs -f`.

## Start the services

Open a terminal for each service. In each terminal, run the following from the
repository root, replacing `SERVICE` and `PORT_VARIABLE` with the matching
values in the table:

```sh
cd SERVICE
set -a; source ../.env; set +a
dart_frog dev --port "$PORT_VARIABLE"
```

| Service directory | Port variable | Port |
| --- | --- | ---: |
| `product-service` | `PRODUCT_SERVICE_PORT` | 8086 |
| `category-service` | `CATEGORY_SERVICE_PORT` | 8082 |
| `auth-service` | `AUTH_SERVICE_PORT` | 8081 |
| `order-service` | `ORDER_SERVICE_PORT` | 8084 |
| `payment-service` | `PAYMENT_SERVICE_PORT` | 8085 |
| `merchant-service` | `MERCHANT_SERVICE_PORT` | 8083 |
| `api-gateway` | `API_GATEWAY_PORT` | 8080 |

For example, start `product-service` with:

```sh
cd product-service
set -a; source ../.env; set +a
dart_frog dev --port "$PRODUCT_SERVICE_PORT"
```

The gateway is the client entry point at `http://localhost:8080`. For example,
`POST /api/v1/auth/login`, `GET /api/v1/products`, and `GET /api/v1/categories` route to
their corresponding services. Merchant operations are available through
`/api/v1/merchant/...`.

The shared `JWT_SECRET` in `.env` is used by all services. Keep `.env` private.
Order, payment, and product services also use the same private
`INTERNAL_SERVICE_TOKEN` for protected inventory operations; keep it private as
well.
Payment checkout also requires provider credentials (`STRIPE_SECRET_KEY`,
`STRIPE_WEBHOOK_SECRET`, `PAYPAL_CLIENT_ID`, and `PAYPAL_CLIENT_SECRET`) before
Stripe or PayPal checkout can complete. For an offline local demo, the provided
`PAYMENT_DEMO_MODE=true` setting enables simulated checkout with
`"provider":"demo"`; this marks the order paid without contacting a payment
provider or moving money. Use `POST /api/v1/payments/demo/complete` with the
returned `payment_id` to finish the simulation. Turn demo mode off outside local
demos.

## Current feature gaps

This is a working microservice foundation, not yet a complete production store.
Orders reserve stock at creation. Successful payments issue one clearly fake
`DEMO-` serial code per unit and attach the codes to the customer's order.
Stock held by an unpaid or abandoned order is not automatically released yet.
Shipping, taxes, refunds, and a storefront UI or admin dashboard are not
implemented yet. The generated codes are demo placeholders, not valid software
licenses; replace them with real license inventory before selling software.
