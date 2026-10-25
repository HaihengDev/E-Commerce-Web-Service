Product service

Product records include `merchant_name`, which is filled from the authenticated
merchant account name, and `merchant_id`, which identifies the owner. Existing
records without an owner remain readable but cannot be updated or deleted by a
merchant through the protected API.

Product creation, update, deletion, and patch requests require a merchant JWT.
Configure `JWT_SECRET` to the same value used by auth-service.

Order-service reserves stock when an order is created. After successful
payment, payment-service asks product-service to generate `DEMO-` serial codes
for each purchased unit. These fake codes are stored with the order for the
customer to retrieve; they are not valid software licenses. Set the same
private `INTERNAL_SERVICE_TOKEN` in order-service, payment-service, and
product-service to protect these service-to-service operations.

Redis caches product list and item reads for 60 seconds by default. Start the
shared Redis instance from the repository root with `docker compose up -d redis`.
Set `REDIS_URL` (default `redis://localhost:6379`) and optionally
`REDIS_CACHE_TTL_SECONDS` to change the cache TTL. Redis is best-effort: MongoDB
remains the source of truth and requests continue if Redis is unavailable.
