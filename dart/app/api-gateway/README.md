# API gateway

The gateway provides one client entry point for the e-commerce services. Run
the services on their documented ports, then start the gateway from this
directory:

```sh
dart_frog dev --port 8080
```

Requests use `/api/v1/<service>/<service-route>`. The gateway forwards the HTTP
method, path, query string, headers, and body, and returns the upstream status,
headers, and response body.

| Gateway route | Default upstream |
| --- | --- |
| `/api/v1/auth/*` | `http://localhost:8003/*` |
| `/api/v1/products/*` | `http://localhost:8000/*` |
| `/api/v1/categories/*` | `http://localhost:8001/categories/*` |
| `/api/v1/orders` | `http://localhost:8004/` |
| `/api/v1/payments/*` | `http://localhost:8005/*` |
| `/api/v1/merchant/*` | `http://localhost:8002/*` |

For example, `POST /api/v1/auth/login` is forwarded to `POST /login` on
auth-service, `GET /api/v1/products` is forwarded to `GET /` on product-service,
and `GET /api/v1/orders` is forwarded to the order-service root route.

Override upstream base URLs with `AUTH_SERVICE_URL`, `PRODUCT_SERVICE_URL`,
`CATEGORY_SERVICE_URL`, `ORDER_SERVICE_URL`, `PAYMENT_SERVICE_URL`, and
`MERCHANT_SERVICE_URL`. Defaults target local development ports. Configure
these with service DNS names when running the gateway in containers.

The gateway returns `404` for unknown service prefixes and `502` when an
upstream cannot be reached. The existing `merchant-service` remains useful as
an aggregation layer for merchant operations; `/api/v1/merchant/*` forwards to it.
