#!/usr/bin/env bash
# Adds (or updates) Google as an identity provider of the local realm `lifeos`, from GOOGLE_CLIENT_ID and
# GOOGLE_CLIENT_SECRET in ../.env. Works on a running stack without wiping it; run again after `down -v`.
set -euo pipefail
cd "$(dirname "$0")/.."

if [[ -f .env ]]; then
  set -a; source .env; set +a
fi
: "${GOOGLE_CLIENT_ID:?Set GOOGLE_CLIENT_ID in local/.env (see .env.example)}"
: "${GOOGLE_CLIENT_SECRET:?Set GOOGLE_CLIENT_SECRET in local/.env (see .env.example)}"

kcadm() { docker compose exec -T keycloak /opt/keycloak/bin/kcadm.sh "$@"; }

kcadm config credentials --server http://localhost:8180 --realm master --user admin --password admin >/dev/null

# Google verifies e-mail addresses, so they are trusted: a Google account with the e-mail of an existing user is
# offered to be linked to it. The mobile app skips Keycloak's login page with kc_idp_hint=google.
settings=(
  -s alias=google -s providerId=google -s enabled=true -s trustEmail=true
  -s firstBrokerLoginFlowAlias="first broker login"
  -s config.clientId="$GOOGLE_CLIENT_ID" -s config.clientSecret="$GOOGLE_CLIENT_SECRET"
  -s config.defaultScope="openid profile email" -s config.syncMode=IMPORT
)

if kcadm get identity-provider/instances/google -r lifeos >/dev/null 2>&1; then
  kcadm update identity-provider/instances/google -r lifeos "${settings[@]}"
  echo "Updated the Google identity provider of realm lifeos."
else
  kcadm create identity-provider/instances -r lifeos "${settings[@]}"
  echo "Added the Google identity provider to realm lifeos."
fi
