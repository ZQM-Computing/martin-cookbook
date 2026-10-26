# 03 — MapLibre Client: Consuming Martin Tiles in a Web Map

> Status: design-only, gate 1 target. This pattern has not run.
> Exact MapLibre version, tile URL template, and CORS behavior are
> to confirm at validation in a real browser.

## What it demonstrates

Consuming Martin vector tiles in a MapLibre GL JS map: fetch the
function source's TileJSON (pattern 02), wire its tile template into
a MapLibre vector source, and style the synthetic points as circles
sized by their `value` attribute. The map is a single static HTML
file served locally — no build step, no framework, no tile cache.

## Prerequisites + versions

- A running Martin instance serving the `synthetic_points_fn`
  function source (pattern 02) or the `01-table-source` table source
  (implemented separately in this repo).
- A browser (name/version: to confirm at validation).
- MapLibre GL JS version: to confirm at validation — the HTML pins
  a major version (`@4`) as a design placeholder; validation pins
  the exact version and records it here.
- Python 3 (stdlib `http.server`) for local serving, or any static
  file server you already run.

## Steps

1. Set `<MARTIN_URL>` inside `index.html` (the TileJSON URL for
   your source).
2. Serve this directory and open the page:

   ```bash
   bash serve.sh
   # then open http://127.0.0.1:8000/ in a browser
   ```

3. Confirm the synthetic points render as circles over the base map
   (base style: a plain background in this pattern — no third-party
   basemap is required or assumed).

## Expected output

- The map loads without console errors; the vector source reports
  its tiles loading (network tab shows `.pbf` requests to Martin).
- 12 synthetic points render as circles, larger for larger `value`.
- Panning/zooming re-requests tiles from Martin (live generation,
  not a cache — verify in the network tab).
- Exact rendering and console output are to confirm at validation;
  the description above is the design expectation, not a recorded
  run.

## Failure behavior

- Blank map, no tile requests: `<MARTIN_URL>` is wrong or Martin is
  not running — check `/catalog` first (patterns 01–02), not the
  HTML.
- Tile requests blocked by the browser (CORS): whether Martin's
  CORS behavior allows browser-origin requests in the validation
  build is to confirm at validation; if blocked, serve the page
  from the same origin as Martin or record the CORS setting the
  deployment needs. Do not disable browser security to "fix" it.
- Points missing at some zooms: the function's extent filter or
  the layer's `minzoom`/`maxzoom` (see the HTML comments) — check
  the tile bytes for those zooms before restyling.

## To confirm at validation

- Exact pinned MapLibre GL JS version + CSS URL.
- TileJSON-to-source wiring: exact `tiles` template and
  `source-layer` name for the function source.
- CORS behavior of the Martin build used, and the deployment's
  answer to it.
- Circle styling expressions against the real `value` attribute
  range (5–90 in the synthetic data).
