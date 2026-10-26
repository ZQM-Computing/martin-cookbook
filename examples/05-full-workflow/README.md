# 05 — Full Workflow: PostGIS Table → Martin Tiles → Web Map

> Status: design-only, gate 1 target. This pattern has not run.
> It chains patterns 01–04; every step's individual open questions
> apply here too, and are not re-listed in full.

## What it demonstrates

The end-to-end Martin story in one script: create the synthetic
points table, prove Martin serves it as tiles (table source from
pattern 01, function source from pattern 02), prove the service
stays healthy (pattern 04's checks), and hand off to the web map
(pattern 03) as the final, manual step. The script aborts on the
first failed step, so a green run means the whole chain held.

## Prerequisites + versions

- Martin **1.15.0 or 1.16.1** running (pattern 04's deployment)
  against a Postgres/PostGIS database you own.
- The sibling pattern scripts present in this repo's `examples/`
  directory (02 `serve.sh` checks, 03 `index.html`, 04 `deploy.sh`
  checks).
- Placeholders: `<PG_DSN>`, `<MARTIN_URL>`. No real credential is
  shipped or committed.

## Steps

1. Set the placeholders (export them, or edit the top of
   `workflow.sh`).
2. Run:

   ```bash
   bash workflow.sh
   ```

3. Final manual step: serve pattern 03's directory and open the
   map in a browser (the script prints the command).

## Expected output (checklist — all must pass)

- [ ] Table: 12 synthetic points created (this pattern's
  `table.sql`, same data as pattern 02's function input).
- [ ] Catalog: `/catalog` 200 listing the table and/or function
  sources.
- [ ] Tile: one tile request per source returns MVT bytes (200).
- [ ] TileJSON: one TileJSON per source describes the vector layer.
- [ ] Map: pattern 03's page renders the points (manual, browser).
- Exact bodies and counts are to confirm at validation; the
  checklist above is the design expectation, not a recorded run.

## Failure behavior

- The script uses `set -euo pipefail`: the first failing step
  stops the run and names the step. Fix that step's pattern
  (01, 02, or 04) — do not skip ahead, because later steps depend
  on earlier state (table, registered sources, a healthy service).
- Re-running after a partial run: `table.sql` is idempotent
  (`CREATE TABLE IF NOT EXISTS` + `ON CONFLICT DO NOTHING`), so
  re-runs are safe for the table; source registration follows
  Martin's startup, not this script.
- A green run here does not claim gate 3 for any single pattern:
  each pattern's own validation questions still need their own
  recorded runs.

## To confirm at validation

- Everything listed under patterns 01–04, especially: function
  signature per version (02), MapLibre pin + CORS (03), and
  config/CLI spelling per version (04).
- The node the full chain runs against, and the Postgres/PostGIS
  versions there.
