# 02 — Function Source: Parameterized Tiles from SQL

> Status: design-only, gate 1 target. This pattern has not run.
> Exact function-source signature handling differs by Martin
> version and is to confirm at validation (see below).

## What it demonstrates

A Martin function source: a Postgres function that takes tile
coordinates (plus optional query parameters) and returns Mapbox
Vector Tile bytes for a synthetic points table, served without a
pre-rendered cache. Compared with pattern 01's table source, the
function source adds parameters — bbox filtering, attribute
filtering, and simplification — decided in SQL at request time.

## Prerequisites + versions

- Postgres with PostGIS and a synthetic points table (created by
  `function.sql` in this pattern — 12 points around an arbitrary
  origin, not a real place).
- Martin **1.15.0 or 1.16.1**. Version behavior that matters here
  (fleet-observed, design context only):
  - 1.15.0 rejects `--postgres` (do not pass it; use a config file
    or the version's supported connection form).
  - 1.16.1 ignores the `srv` config key and takes CLI flags.
  - Both versions verified `/catalog` and tile endpoints on the
    fleet against Natural Earth tables — this pattern's synthetic
    table is new, not that verification.
- `psql` client; `curl` and `jq` for the checks.
- Connection addressed only as `<PG_DSN>` (placeholder).

## Steps

1. Create the table and function:

   ```bash
   psql "<PG_DSN>" -v ON_ERROR_STOP=1 -f function.sql
   ```

2. Serve Martin (see `serve.sh` for the version-branched
   invocation) and check the catalog:

   ```bash
   bash serve.sh
   ```

   The script prints the function source's entry from `/catalog`
   and fetches one tile plus its TileJSON.

## Expected output

- `/catalog` lists the function source (name: `synthetic_points_fn`
  in this pattern; exact catalog key spelling to confirm at
  validation per Martin version).
- TileJSON for the source describes vector layers matching the
  function's output (one layer, point geometry).
- One tile request inside the synthetic points' extent returns MVT
  bytes (HTTP 200, non-empty body); a tile outside the extent
  returns an empty-but-valid tile, not an error.
- Exact catalog JSON, TileJSON fields, and tile bytes are to
  confirm at validation; the shapes above are the design
  expectation, not a recorded run.

## Failure behavior

- Function source missing from `/catalog`: the function signature
  does not match what the running Martin version accepts (argument
  names/types, return type, or schema visibility). Check the
  function definition against the version's documented signature
  and Martin's startup log — do not rename the table source to
  "fix" a function-source problem.
- Empty tiles everywhere: the function's tile-envelope filter is
  wrong (wrong SRID, wrong envelope function) — compare against
  the table source (pattern 01) for the same table.
- Connection failure: Martin exits at startup; check `<PG_DSN>`
  and that PostGIS is installed — do not re-create the function
  to "fix" a connection failure.

## To confirm at validation

- Exact function-source signature per Martin version (argument
  order/names, `query_params` JSON handling, return type `bytea`).
- Catalog key spelling for function sources in 1.15.0 vs 1.16.1.
- Config-file schema (if used) vs CLI flags per version.
- Whether query parameters (e.g. a minimum-value filter) pass
  through the tile URL in each version, and their exact spelling.
- `ST_AsMVT` / `ST_TileEnvelope` behavior for the synthetic data
  (empty-tile vs error semantics at extent edges).
