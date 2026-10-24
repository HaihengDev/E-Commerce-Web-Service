# API gateway

The gateway provides one client entry point for the e-commerce services. Run
the services on their documented ports, then start the gateway from this
directory:

```sh
dart_frog dev --port 8080
```

Requests use `/api/<service>/<service-route>`. The gateway forwards the HTTP
method, path, query string, headers, and body, and returns the upstream status,
headers, and response body.

| Gateway route | Default upstream |
| --- | --- |
| `/api/auth/*` | `http://localhost:8003/*` |
| `/api/products/*` | `http://localhost:8000/*` |
| `/api/categories/*` | `http://localhost:8001/categories/*` |
| `/api/orders/*` | `http://localhost:8004/orders/*` |
| `/api/payments/*` | `http://localhost:8005/*` |
| `/api/merchant/*` | `http://localhost:8002/*` |

For example, `POST /api/auth/login` is forwarded to `POST /login` on
auth-service, `GET /api/products` is forwarded to `GET /` on product-service,
and `GET /api/orders` is forwarded to `GET /orders` on order-service.

Override upstream base URLs with `AUTH_SERVICE_URL`, `PRODUCT_SERVICE_URL`,
`CATEGORY_SERVICE_URL`, `ORDER_SERVICE_URL`, `PAYMENT_SERVICE_URL`, and
`MERCHANT_SERVICE_URL`. Defaults target local development ports. Configure
these with service DNS names when running the gateway in containers.

The gateway returns `404` for unknown service prefixes and `502` when an
upstream cannot be reached. The existing `merchant-service` remains useful as
an aggregation layer for merchant operations; `/api/merchant/*` forwards to it.
