Product service

Product records include `merchant_name`, which identifies the merchant shown
with a product. Include it when creating a product and in full (`PUT`) updates.
For example, `{"merchant_name":"Acme Store"}` is the owner label returned by
`GET /` and `GET /:id`. Existing records without this field remain readable;
set the name with `PATCH /:id` to populate them.
