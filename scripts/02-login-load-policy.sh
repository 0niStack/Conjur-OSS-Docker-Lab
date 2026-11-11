#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
set -a; source .env; set +a
C="docker compose exec -T client"

$C conjur init -u https://proxy -a "$CONJUR_ACCOUNT" --self-signed --force
$C conjur login -i admin -p "$(cat .admin_api_key)"
OUT=$($C conjur policy load -b root -f /policy/root.yml)
echo "$OUT"

# Save host API key (only returned the first time the host is created)
if [ ! -f .host_api_key ]; then
  echo "$OUT" | python3 -c 'import sys,json; d=json.load(sys.stdin); print(list(d["created_roles"].values())[0]["api_key"])' > .host_api_key
  chmod 600 .host_api_key
  echo "myapp API key saved to .host_api_key"
fi
