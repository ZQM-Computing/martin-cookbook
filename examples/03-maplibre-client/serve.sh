#!/usr/bin/env bash
# 03-maplibre-client: serve this directory locally, then open the
# page in a browser. Design-only: rendering is to confirm in a
# real browser at validation.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
grep -q '<MARTIN_URL>' "$SCRIPT_DIR/index.html" \
  && echo "NOTE: set <MARTIN_URL> inside index.html first." >&2 || true
cd "$SCRIPT_DIR"
echo "Serving on http://127.0.0.1:8000/ — open it in a browser."
python3 -m http.server 8000
