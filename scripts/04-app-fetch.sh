#!/usr/bin/env bash
# Simulates an application: authenticates as host/myapp and fetches secrets via REST API
set -euo pipefail
cd "$(dirname "$0")/.."
set -a; source .env; set +a

URL="https://localhost:8443"
CA="certs/server.crt"
API_KEY=$(cat .host_api_key)

TOKEN=$(curl -sf --cacert "$CA" -d "$API_KEY" \
  "$URL/authn/$CONJUR_ACCOUNT/host%2Fmyapp/authenticate" | base64 | tr -d '\r\n')

get() { curl -sf --cacert "$CA" -H "Authorization: Token token=\"$TOKEN\"" \
  "$URL/secrets/$CONJUR_ACCOUNT/variable/$1"; }

echo "DB_USER=$(get db-username)"
echo "DB_PASS=$(get db-password)"
