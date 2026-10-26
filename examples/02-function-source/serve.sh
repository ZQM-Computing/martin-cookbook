#!/usr/bin/env bash
# 02-function-source checks. Martin must already be running against
# the database holding synthetic_points + synthetic_points_fn
# (see README for the version-branched invocation).
# Design-only: catalog spelling and tile bytes are to confirm.
set -euo pipefail

MARTIN_URL="${MARTIN_URL:-<MARTIN_URL>}"
if [[ "$MARTIN_URL" == "<MARTIN_URL>" ]]; then
  echo "Set MARTIN_URL first (and start Martin per the README)." >&2
  exit 2
fi

echo "--- /catalog (expect a synthetic_points_fn source entry) ---"
curl -fsS "$MARTIN_URL/catalog" | jq .

echo "--- TileJSON for the function source ---"
curl -fsS "$MARTIN_URL/synthetic_points_fn.json" | jq . \
  || echo "(TileJSON path spelling to confirm at validation)"

echo "--- one tile inside the synthetic extent (expect MVT bytes) ---"
curl -fsS -o /tmp/martin-fn-tile.mvt "$MARTIN_URL/synthetic_points_fn/0/0/0.pbf" \
  || echo "(tile path spelling to confirm at validation)"
ls -l /tmp/martin-fn-tile.mvt 2>/dev/null || true

cat <<'EOF'
Version-branched serve notes (placeholders; spelling to confirm):
- Martin 1.16.1: CLI flags govern (the `srv` config key is ignored).
  Example shape: martin --postgres "<PG_DSN>" --listen-addresses 127.0.0.1:3000
- Martin 1.15.0: do NOT pass --postgres (rejected); use the version's
  supported connection form (config file) instead.
- Fleet port context only: Node-3 serves Martin on 3002 (not 3001).
  This pattern addresses Martin only as <MARTIN_URL>.
EOF
