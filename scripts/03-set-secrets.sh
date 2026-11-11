#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."
C="docker compose exec -T client"
$C conjur variable set -i db-username -v "appuser"
$C conjur variable set -i db-password -v "${1:-S3cr3t-P@ssw0rd}"
echo "--- read back as admin ---"
$C conjur variable get -i db-password
