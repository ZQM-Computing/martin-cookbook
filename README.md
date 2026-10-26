# Martin Cookbook

<!-- ZQM-START -->
<!-- markdownlint-disable MD033 -->
<p align="center">
  <strong>ZQM Computing — Geospatial Engineering & Scientific Computing</strong><br>
  <a href="https://github.com/ZQM-Computing">ZQM Computing</a>
</p>
<!-- markdownlint-enable MD033 -->
<!-- ZQM-END -->

![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)

A **Martin cookbook** for serving vector tiles straight from PostGIS, with function sources and tile serving at scale. Patterns are drawn from the ZQM fleet's running Martin installs (1.15.0 on Node-1, 1.16.1 on Node-3, both verified `/catalog` and tile endpoints against Natural Earth tables in PostGIS). It is intended for GIS engineers and web-mapping developers who want live vector tiles without a tile cache; validate each pattern against your own data, software versions, and operating environment before adopting it.

## Repository role and status

**Status:** Active, public — first executable table-source pattern added. The pinned-runtime CI smoke test is the evidence gate for catalog, TileJSON, and tile endpoint behavior.

**What this repository is:** Martin patterns — Postgres table sources, function sources, tile endpoints, and service deployment.

**What it contributes:** Part of the ZQM Computing geospatial portfolio. The umbrella index for the series is [geospatial-cookbooks](https://github.com/ZQM-Computing/geospatial-cookbooks).

**Standing:** This repository is maintained independently. Automated checks cover only the paths and environments configured in its workflows; they do not establish production readiness or operational certification.

## Who this is for

Geospatial developers building web maps with MapLibre or similar clients, who want tiles generated live from their database rather than pre-rendered.

## Prerequisites

- Martin 1.15.0 or 1.16.1 (note version-specific behavior: 1.15.0 rejects `--postgres`; 1.16.1 ignores the `srv` config key and takes CLI flags)
- Postgres with PostGIS and a table to serve (see [postgis-cookbook](https://github.com/ZQM-Computing/postgis-cookbook))
- Bash

## Patterns

| # | Example | Status | What it demonstrates |
|---|---------|--------------------------|
| 01 | [01-table-source](examples/01-table-source/README.md) | Implemented; CI validation pending | Explicit PostGIS table source; `/catalog`, TileJSON, and tile smoke test |
| 02 | [02-function-source](examples/02-function-source/README.md) | Written — design-only, gate 1 target | Function sources for parameterized tiles (bbox, filters, simplification) |
| 03 | [03-maplibre-client](examples/03-maplibre-client/README.md) | Written — design-only, gate 1 target | Consuming Martin tiles in a MapLibre GL JS map (see maplibre-cookbook) |
| 04 | [04-service-deploy](examples/04-service-deploy/README.md) | Written — design-only, gate 1 target | Running Martin as a service with connection settings and health checks |
| 05 | [05-full-workflow](examples/05-full-workflow/README.md) | Written — design-only, gate 1 target | End-to-end: PostGIS table → Martin tiles → web map |

## Repository layout

```text
martin-cookbook/
├── examples/01-table-source/  # explicit PostGIS table source
├── tests/                    # contract and live smoke tests
├── .github/workflows/        # disposable PostGIS integration CI
├── README.md
└── LICENSE
```

## Roadmap

- First pattern pass: table source (01), then function source (02)
- Second pass: client + deployment (03, 04)
- Version-notes page covering the 1.15.0 / 1.16.1 CLI and config differences found on the fleet

## Contributing

A contributing guide lands with the first pattern pass. Report security issues to <zqmcomputing@gmail.com> — please do not open a public issue for those.

## More from this series

- [postgis-cookbook](https://github.com/ZQM-Computing/postgis-cookbook) — PostGIS SQL examples: spatial indexing, joins & KNN, SRID management, vector tiles, data quality, partitioning
- [maplibre-cookbook](https://github.com/ZQM-Computing/maplibre-cookbook) — MapLibre GL JS custom layers, 3D terrain, performance tuning, interactive maps
- [geoserver-cookbook](https://github.com/ZQM-Computing/geoserver-cookbook) — Publishing, styling, federation, and securing OGC services with GeoServer and PostGIS
