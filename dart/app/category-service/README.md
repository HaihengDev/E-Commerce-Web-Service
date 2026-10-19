# Category service

Run from this directory with `dart_frog dev`. By default, the API listens on
port 8000; set `CATEGORY_SERVICE_PORT=8001` when starting it alongside the
product service.

Configure `MONGO_URI_CATEGORY_SERVICE` to point to a MongoDB database. The
service exposes `GET /categories`, `POST /categories`, and
`GET|PUT|DELETE /categories/:id`. Create requests use `category_name` and an
optional `description`. IDs are generated as `CAT0001`, etc.

Set `CATEGORY_SERVICE_URL` in product-service to the category service base URL
(for example, `http://localhost:8001/categories`). Product `category` fields
must contain an existing `category_id`.
