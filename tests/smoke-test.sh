#!/usr/bin/env bash
set -Eeuo pipefail

: "${DATABASE_URL:?Set DATABASE_URL for the disposable PostGIS database}"
MARTIN_URL="${MARTIN_URL:-http://127.0.0.1:3000}"
tmpdir="$(mktemp -d)"
server_log="$tmpdir/martin.log"
cleanup() {
  if [[ -n "${MARTIN_PID:-}" ]]; then
    kill "$MARTIN_PID" 2>/dev/null || true
    wait "$MARTIN_PID" 2>/dev/null || true
  fi
  if [[ "${KEEP_MARTIN_LOG:-0}" == "1" ]]; then
    cat "$server_log"
  fi
  rm -rf "$tmpdir"
}
trap cleanup EXIT

docker run --rm --network host \
  --env DATABASE_URL \
  --volume "$PWD/examples/01-table-source/config.yaml:/config.yaml:ro" \
  ghcr.io/maplibre/martin:1.16.1 --config /config.yaml >"$server_log" 2>&1 &
MARTIN_PID=$!

ready=0
for _ in $(seq 1 45); do
  if curl --fail --silent "$MARTIN_URL/catalog" >"$tmpdir/catalog.json"; then
    ready=1
    break
  fi
  if ! kill -0 "$MARTIN_PID" 2>/dev/null; then
    cat "$server_log" >&2
    echo "Martin exited before becoming ready." >&2
    exit 1
  fi
  sleep 2
done
if [[ "$ready" != "1" ]]; then
  cat "$server_log" >&2
  echo "Martin did not become ready within 90 seconds." >&2
  exit 1
fi

python - "$tmpdir/catalog.json" <<'PY'
import json
import sys
with open(sys.argv[1], encoding="utf-8") as stream:
    catalog = json.load(stream)
ids = {entry.get("id") or entry.get("name") for entry in catalog}
if "places" not in ids:
    raise SystemExit(f"places source missing from Martin catalog: {sorted(str(x) for x in ids)}")
PY

curl --fail --silent "$MARTIN_URL/places" >"$tmpdir/tilejson.json"
python - "$tmpdir/tilejson.json" <<'PY'
import json
import sys
with open(sys.argv[1], encoding="utf-8") as stream:
    tilejson = json.load(stream)
if not tilejson.get("tiles"):
    raise SystemExit("TileJSON did not contain tile URLs")
if not tilejson.get("vector_layers"):
    raise SystemExit("TileJSON did not contain vector layer metadata")
PY

curl --fail --silent --show-error "$MARTIN_URL/places/0/0/0" -o "$tmpdir/tile.pbf"
if [[ ! -s "$tmpdir/tile.pbf" ]]; then
  echo "Tile endpoint returned an empty body for the synthetic fixture." >&2
  exit 1
fi
printf 'Martin smoke test passed: catalog, TileJSON, and tile (%s bytes).\n' "$(wc -c < "$tmpdir/tile.pbf")"
