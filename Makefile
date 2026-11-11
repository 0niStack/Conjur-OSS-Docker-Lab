.PHONY: up policy secrets fetch all logs destroy
all: up policy secrets fetch
up:      ; ./scripts/01-up.sh
policy:  ; ./scripts/02-login-load-policy.sh
secrets: ; ./scripts/03-set-secrets.sh
fetch:   ; ./scripts/04-app-fetch.sh
logs:    ; docker compose logs -f conjur
destroy: ; ./scripts/99-destroy.sh
