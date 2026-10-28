# Order service

Run with `dart_frog dev --port 8004`. Configure `MONGO_URI_ORDER_SERVICE` and
the same `JWT_SECRET` used by the authentication service.

- `POST /` creates a pending order for an authenticated `user` role. The
  body is `{"items":[{"product_id":"PRD0001","quantity":2}]}`.
- `GET /` lists only the authenticated user's orders.

Order creation reserves requested stock through product-service. If any line is
unavailable, the order is rejected with `409 Conflict`. If saving the order
fails after reservation, the service asks product-service to release that
stock. Orders store product IDs and quantities; checkout prices are calculated
from current product prices by payment-service.
An unpaid order keeps its reserved stock; automatic expiration and customer
cancellation are not implemented yet.

Configure `PRODUCT_SERVICE_URL` and the same private `INTERNAL_SERVICE_TOKEN`
in order-service and product-service. Only product-service's protected
internal routes can change stock or issue serial codes.

After successful payment, each order item includes one `serial_codes` entry per
unit. These are clearly marked `DEMO-` fake codes for local demonstrations;
they are not valid software licenses.
