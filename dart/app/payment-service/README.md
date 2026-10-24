# Payment service

Sandbox checkout API for Stripe Checkout and PayPal Orders v2. Start with
`dart_frog dev --port 8005` from this directory. It uses the order service's
MongoDB (`MONGO_URI_ORDER_SERVICE`) and verifies the same `JWT_SECRET` used by
the other services. It reads current prices from product-service, so create an
order first and do not send an amount from the client.

Configure environment variables (keep secrets out of source control):

```dotenv
MONGO_URI_ORDER_SERVICE=mongodb://localhost:27017/ecommerce
JWT_SECRET=<same-secret-as-other-services-at-least-32-characters>
PRODUCT_SERVICE_URL=http://localhost:8001
STRIPE_SECRET_KEY=sk_test_...
STRIPE_WEBHOOK_SECRET=whsec_...
PAYPAL_CLIENT_ID=...
PAYPAL_CLIENT_SECRET=...
PAYPAL_BASE_URL=https://api-m.sandbox.paypal.com
```

Endpoints:

- `POST /` with a user bearer token and `{"order_id":"...","provider":"stripe|paypal","return_url":"https://...","cancel_url":"https://..."}` creates a provider checkout and returns its URL.
- `POST /capture` with `{"paypal_order_id":"..."}` captures an approved PayPal order.
- `POST /stripe-webhook` receives Stripe events. Set the endpoint's signing secret as `STRIPE_WEBHOOK_SECRET`; `checkout.session.completed` marks the payment and order paid. Configure this webhook in Stripe or forward local events with Stripe CLI.

Use Stripe test mode credentials and PayPal Sandbox credentials. Checkout totals
are calculated in USD from product prices and percentage discounts. Orders and
payments are marked paid only after PayPal capture or a verified Stripe webhook.
The API does not support refunds, taxes, shipping, or inventory reservation.
