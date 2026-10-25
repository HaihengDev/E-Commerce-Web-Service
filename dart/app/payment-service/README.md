# Payment service

Sandbox checkout API for Stripe Checkout and PayPal Orders v2. Start with
`dart_frog dev --port 8005` from this directory. It uses the order service's
MongoDB (`MONGO_URI_ORDER_SERVICE`) and verifies the same `JWT_SECRET` used by
the other services. It reads current prices from product-service, so create an
order first and do not send an amount from the client.

Configure environment variables (keep secrets out of source control):

```dotenv
MONGO_URI_ORDER_SERVICE=mongodb://localhost:27017/ecommerce_orders
JWT_SECRET=<same-secret-as-other-services-at-least-32-characters>
PRODUCT_SERVICE_URL=http://localhost:8086
STRIPE_SECRET_KEY=sk_test_...
STRIPE_WEBHOOK_SECRET=whsec_...
PAYPAL_CLIENT_ID=...
PAYPAL_CLIENT_SECRET=...
PAYPAL_BASE_URL=https://api-m.sandbox.paypal.com
PAYMENT_DEMO_MODE=true
```

For a local demo without payment-provider accounts, set
`PAYMENT_DEMO_MODE=true` and create checkout with `"provider":"demo"`. This
simulates approval; it does not contact Stripe or PayPal and does not move real
money. The response includes a `payment_id` and a `next_step`. Send that
`payment_id` with the same user's bearer token to
`POST /api/payments/demo/complete` to mark the demo payment and order paid.
Disable demo payments by setting `PAYMENT_DEMO_MODE=false` when you do not want
the simulated completion route available.

After any payment method succeeds, payment-service asks product-service to
issue one fake serial code per unit, then stores those codes on the paid order.
The customer can retrieve them using `GET /api/orders` with their user token.
These `DEMO-` codes are placeholders for demonstrating digital fulfillment,
not valid software licenses.

Endpoints:

- `POST /` with a user bearer token and `{"order_id":"...","provider":"stripe|paypal|demo","return_url":"https://...","cancel_url":"https://..."}` creates a checkout. Demo mode does not require return or cancel URLs.
- `POST /demo/complete` with a user bearer token and `{"payment_id":"..."}` completes a simulated payment when demo mode is enabled.
- `POST /capture` with `{"paypal_order_id":"..."}` captures an approved PayPal order.
- `POST /stripe-webhook` receives Stripe events. Set the endpoint's signing secret as `STRIPE_WEBHOOK_SECRET`; `checkout.session.completed` marks the payment and order paid. Configure this webhook in Stripe or forward local events with Stripe CLI.

Use Stripe test mode credentials and PayPal Sandbox credentials for real
provider sandbox flows. Checkout totals are calculated in USD from product
prices and percentage discounts. Provider payments are marked paid only after
PayPal capture or a verified Stripe webhook. Demo payments are clearly marked
as simulated. The API does not support refunds, taxes, or shipping.
