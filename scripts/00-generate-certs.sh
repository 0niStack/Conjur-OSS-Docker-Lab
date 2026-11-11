#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
mkdir -p certs
if [ -f certs/server.crt ]; then echo "certs exist, skipping"; exit 0; fi
openssl req -x509 -newkey rsa:4096 -nodes -days 365 \
  -keyout certs/server.key -out certs/server.crt \
  -subj "/CN=localhost" \
  -addext "subjectAltName=DNS:localhost,DNS:proxy,IP:127.0.0.1"
echo "Self-signed cert created in certs/"
