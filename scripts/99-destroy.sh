#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
docker compose down -v
rm -rf certs .env .admin_api_key .host_api_key
echo "Everything removed."
