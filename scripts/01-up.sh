#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
./scripts/00-generate-certs.sh

if [ ! -f .env ]; then
  cp .env.example .env
  DK=$(docker run --rm cyberark/conjur data-key generate)
  PW=$(openssl rand -hex 16)
  sed -i "s|^CONJUR_DATA_KEY=.*|CONJUR_DATA_KEY=${DK}|; s|^POSTGRES_PASSWORD=.*|POSTGRES_PASSWORD=${PW}|" .env
  echo ".env created with generated data key + DB password"
fi
set -a; source .env; set +a

docker compose up -d
echo "Waiting for Conjur..."
for i in $(seq 1 30); do
  if docker compose exec -T conjur conjurctl wait >/dev/null 2>&1; then break; fi
  sleep 3
done

if [ ! -f .admin_api_key ]; then
  OUT=$(docker compose exec -T conjur conjurctl account create "$CONJUR_ACCOUNT")
  echo "$OUT"
  echo "$OUT" | grep -i "API key for admin" | awk '{print $NF}' | tr -d '\r' > .admin_api_key
  chmod 600 .admin_api_key
  echo "Admin API key saved to .admin_api_key"
fi
