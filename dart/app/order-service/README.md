# Order service

Run with `dart_frog dev --port 8004`. Configure `MONGO_URI_ORDER_SERVICE` and
the same `JWT_SECRET` used by the authentication service.

- `POST /orders` creates a pending order for an authenticated `user` role. The
  body is `{"items":[{"product_id":"PRD0001","quantity":2}]}`.
- `GET /orders` lists only the authenticated user's orders.

Order requests store product IDs and quantities. Payment, price snapshots,
inventory reservation, and stock updates are not implemented yet.
