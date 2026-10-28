FROM dart:stable

WORKDIR /app

RUN dart pub global activate dart_frog_cli
ENV PATH="/root/.pub-cache/bin:${PATH}"

COPY auth-service/ /app/auth-service/
COPY category-service/ /app/category-service/
COPY merchant-service/ /app/merchant-service/
COPY order-service/ /app/order-service/
COPY payment-service/ /app/payment-service/
COPY product-service/ /app/product-service/
COPY api-gateway/ /app/api-gateway/
COPY docker-entrypoint.sh /app/docker-entrypoint.sh

RUN set -e; for service in auth-service category-service merchant-service order-service payment-service product-service api-gateway; do \
      cd "/app/$service" && dart pub get && dart_frog build; \
    done

RUN chmod +x /app/docker-entrypoint.sh

ENV AUTH_SERVICE_URL=http://127.0.0.1:8081 \
    CATEGORY_SERVICE_URL=http://127.0.0.1:8082/categories \
    MERCHANT_SERVICE_URL=http://127.0.0.1:8083 \
    ORDER_SERVICE_URL=http://127.0.0.1:8084 \
    PAYMENT_SERVICE_URL=http://127.0.0.1:8085 \
    PRODUCT_SERVICE_URL=http://127.0.0.1:8086

EXPOSE 10000
ENTRYPOINT ["/app/docker-entrypoint.sh"]
