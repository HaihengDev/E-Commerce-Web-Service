# Authentication service

Run with `dart_frog dev --port 8003`. Configure `MONGO_URI_AUTH_SERVICE` and
`JWT_SECRET` in the environment. Use the same JWT secret in the merchant,
product, and order services; it must contain at least 32 characters. Generate
one with `openssl rand -hex 32` and keep it out of source control.

- `POST /register` accepts `email`, `password`, `name`, and optional `role`
  (`user` by default; `merchant` for seller accounts). It returns a bearer token.
- `POST /login` accepts `email` and `password` and returns a bearer token.

Passwords are stored as bcrypt hashes. Access tokens expire after one hour.
Registration currently permits self-selection of the merchant role; add a
review/approval flow before using this for a marketplace that requires seller
verification.
