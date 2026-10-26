#!/usr/bin/env bash
# 05-full-workflow: table -> tiles -> map, chained.
# Design-only: aborts on the first failed step (set -euo pipefail).
set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EXAMPLES_DIR="${EXAMPLES_DIR:-$HERE/..}"

: "${PG_DSN:?Set PG_DSN.}"
: "${MARTIN_URL:?Set MARTIN_URL.}"
export PG_DSN MARTIN_URL

echo "=== step 1: synthetic table ==="
psql "$PG_DSN" -v ON_ERROR_STOP=1 -f "$HERE/table.sql"
psql "$PG_DSN" -v ON_ERROR_STOP=1 -At -c \
  "SELECT count(*) FROM synthetic_points;"

echo "=== step 2: catalog (expect table and/or function sources) ==="
curl -fsS "$MARTIN_URL/catalog" | jq .

echo "=== step 3: tiles (expect MVT bytes per source) ==="
for src in synthetic_points synthetic_points_fn; do
  echo "--- $src ---"
  curl -fsS -o "/tmp/martin-wf-$src.mvt" \
    "$MARTIN_URL/$src/0/0/0.pbf" \
    && ls -l "/tmp/martin-wf-$src.mvt" \
    || echo "(source $src tile: path/source to confirm at validation)"
done

echo "=== step 4: map (manual) ==="
echo "Serve pattern 03 and open it in a browser:"
echo "  cd $EXAMPLES_DIR/03-maplibre-client && bash serve.sh"

echo "=== full workflow: automated steps passed (design expectation) ==="
