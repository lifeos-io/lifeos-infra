# Local development stack

Everything a service needs to start on your machine, bound to `127.0.0.1` only. Values here are local test values.

```bash
docker compose up -d                  # PostgreSQL, Kafka + topics, Redis, Keycloak
docker compose --profile tools up -d  # + Kafka UI
docker compose down                   # stop (data kept in volumes)
docker compose down -v                # stop and wipe data (re-runs init.sql and the realm import)
```

| Component | Address | Notes |
| --- | --- | --- |
| PostgreSQL 17 | `localhost:5432` | databases + owners `strategy`, `coach`, `trigger`, `notification`, `keycloak`; trust auth, so services' empty `DB_PASSWORD` works |
| Kafka 3.9 (KRaft) | `localhost:9092` | topics `lifeos.{strategy,coach,trigger}.events.v1`, 6 partitions; auto-create off like production (retry/DLT topics are created by Spring Kafka) |
| Redis 7.4 | `localhost:6379` | gateway rate limiting |
| Keycloak 26.3 | http://localhost:8180 (admin / admin) | realm `lifeos`, client `lifeos-mobile` (public, PKCE S256), audience mapper `lifeos-api`, user `onurcan` / `lifeos` |
| Kafka UI | http://localhost:8085 | only with `--profile tools` |

Every service's defaults (`DB_URL`, `KAFKA_BOOTSTRAP_SERVERS`, `KEYCLOAK_ISSUER_URI`, `JWT_AUDIENCES`) already point here,
so a service starts with no extra configuration.

## Get a token and call a service

`directAccessGrantsEnabled` (password grant) is on for this local realm only, so you can test with curl:

```bash
TOKEN=$(curl -s -X POST http://localhost:8180/realms/lifeos/protocol/openid-connect/token \
  -d grant_type=password -d client_id=lifeos-mobile -d username=onurcan -d password=lifeos | jq -r .access_token)

curl -H "Authorization: Bearer $TOKEN" http://localhost:8081/api/strategy/...
```

The token has `iss=http://localhost:8180/realms/lifeos`, `aud=lifeos-api` and a UUID `sub` (the user ID every service uses).
