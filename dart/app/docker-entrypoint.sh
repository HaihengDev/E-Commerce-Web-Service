#!/usr/bin/env bash
set -u

children=()

stop_children() {
  for pid in "${children[@]}"; do
    kill "$pid" 2>/dev/null || true
  done
  wait 2>/dev/null || true
}
trap stop_children EXIT INT TERM

start_service() {
  local service="$1"
  local port="$2"
  (
    cd "/app/$service"
    export PORT="$port"
    exec dart build/bin/server.dart
  ) &
  children+=("$!")
}

# Render routes external HTTP traffic to PORT. Internal services use fixed
# loopback ports so all service-to-service URLs remain inside this container.
start_service auth-service 8081
start_service category-service 8082
start_service merchant-service 8083
start_service order-service 8084
start_service payment-service 8085
start_service product-service 8086
start_service api-gateway "${PORT:-10000}"

# Keep the container healthy only while every service process is alive.
wait -n "${children[@]}"
exit 1
