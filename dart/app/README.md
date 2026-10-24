# E-commerce services

This repository contains separate Dart Frog services and a public API gateway.
For local development, the services run on your host and MongoDB and Redis run
in Docker. This keeps `localhost` database URLs in `.env` valid.

## Start local dependencies

From the repository root:

```sh
docker compose up -d mongo redis
```

MongoDB is published on `localhost:27017`, and Redis is published on
`localhost:6379`. Data persists in the `mongo-data` and `redis-data` Docker
volumes.

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
`POST /api/auth/login`, `GET /api/products`, and `GET /api/categories` route to
their corresponding services. Merchant operations are available through
`/api/merchant/...`.

The shared `JWT_SECRET` in `.env` is used by all services. Keep `.env` private.
Payment checkout also requires provider credentials (`STRIPE_SECRET_KEY`,
`STRIPE_WEBHOOK_SECRET`, `PAYPAL_CLIENT_ID`, and `PAYPAL_CLIENT_SECRET`) before
Stripe or PayPal checkout can complete. For an offline local demo, the provided
`PAYMENT_DEMO_MODE=true` setting enables simulated checkout with
`"provider":"demo"`; this marks the order paid without contacting a payment
provider or moving money. Use `POST /api/payments/demo/complete` with the
returned `payment_id` to finish the simulation. Turn demo mode off outside local
demos.

## Current feature gaps

This is a working microservice foundation, not yet a complete production store.
Order creation does not reserve or decrement stock, and checkout does not yet
implement shipping, taxes, refunds, or inventory compensation. There is no
storefront UI or admin dashboard in this repository. These require product and
business decisions in addition to code changes.
