# Conjur OSS with Docker

CyberArk Conjur OSS + PostgreSQL + Nginx TLS proxy + Conjur CLI v8, and a demo of an app fetching secrets.

## Layout
```
docker-compose.yml     database, conjur, proxy (TLS :8443), client (CLI)
proxy/nginx.conf       TLS termination -> conjur:80
policy/root.yml        host "myapp", variables db-username / db-password, permissions
scripts/               run in order 01 -> 04
```

## Run (one by one, or `make all`)
```bash
chmod +x scripts/*.sh
./scripts/01-up.sh                  # certs, .env, containers, create account "myorg"
./scripts/02-login-load-policy.sh   # CLI init/login, load policy, save myapp API key
./scripts/03-set-secrets.sh         # set db-username / db-password
./scripts/04-app-fetch.sh           # app authenticates as host/myapp and reads secrets
```

Expected output of the last step:
```
DB_USER=appuser
DB_PASS=S3cr3t-P@ssw0rd
```

## Useful commands
```bash
docker compose exec client conjur whoami
docker compose exec client conjur list
docker compose exec client conjur variable get -i db-password
docker compose exec client conjur policy load -b root -f /policy/root.yml   # after editing policy
```

## Using it from your own app (REST)
1. `POST https://HOST:8443/authn/myorg/host%2Fmyapp/authenticate` with the host API key as body -> token (JSON)
2. base64 the token, send `Authorization: Token token="<b64>"`
3. `GET /secrets/myorg/variable/<id>`

Tokens expire after ~8 minutes; re-authenticate when needed.

## Notes
- Self-signed cert: use `--cacert certs/server.crt` (never `-k` in real use).
- For production use a real cert, an authenticator (e.g. authn-k8s / authn-jwt) instead of host API keys, and back up `CONJUR_DATA_KEY`: losing it means losing all secrets.
- Reset everything: `make destroy`.
