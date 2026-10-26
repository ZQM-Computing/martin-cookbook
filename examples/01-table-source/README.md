# 01 — Serve a PostGIS table

This pattern configures Martin 1.16.1 to publish one explicitly named PostGIS table. It does not rely on automatic publication of every geometry table in a database.

## Requirements

- Martin 1.16.1 (the CI smoke test uses the pinned `ghcr.io/maplibre/martin:1.16.1` image)
- PostgreSQL with PostGIS 3.5 or newer
- A table with a stable integer feature ID, a geometry column in the configured SRID, and only the attributes intended for public tile output
- Bash and curl for the smoke test

## Configuration

Set `DATABASE_URL` in the runtime environment and start Martin with this file:

```bash
export DATABASE_URL='postgresql://martin_reader:REDACTED@db.example:5432/maps'
docker run --rm --network host \
  --env DATABASE_URL \
  --volume "$PWD/examples/01-table-source/config.yaml:/config.yaml:ro" \
  ghcr.io/maplibre/martin:1.16.1 \
  --config /config.yaml
```

Use a dedicated database role with read-only access to the intended schema and table. Do not use a superuser in a deployed service. Restrict network access to the Martin listener and database, and review the table's columns before exposing them as vector-tile properties.

## Endpoints

With the server listening on the default port:

- `GET /catalog` — published source catalog
- `GET /places` — TileJSON for the `places` source
- `GET /places/{z}/{x}/{y}` — vector tile bytes

The included smoke test seeds a synthetic point in a disposable PostGIS database, starts the pinned Martin container, checks that the source appears in the catalog and TileJSON, and requests a tile. A successful HTTP response proves the example can serve a tile for the fixture; it does not prove production throughput, authorization, cache policy, or deployment hardening.

## Reproduce in CI

The repository workflow provisions PostGIS, inserts one synthetic feature, starts Martin on the runner network, and runs `tests/smoke-test.sh`. Do not point the test fixture at a production database.
