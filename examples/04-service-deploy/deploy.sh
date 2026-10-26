#!/usr/bin/env bash
# 04-service-deploy: foreground run + NSSM service sketch.
# Design-only: CLI/config spelling is to confirm per version.
set -euo pipefail

MARTIN_BIN="${MARTIN_BIN:-martin}"
MARTIN_URL="${MARTIN_URL:-<MARTIN_URL>}"
PG_DSN="${PG_DSN:-<PG_DSN>}"

cmd="${1:-help}"
case "$cmd" in
  run)
    if [[ "$PG_DSN" == "<PG_DSN>" ]]; then
      echo "Set PG_DSN first (or use the config-file form)." >&2
      exit 2
    fi
    echo "Foreground run (1.16.1 CLI-flag form; adapt per version):"
    echo "  $MARTIN_BIN --postgres \"$PG_DSN\" --listen-addresses 127.0.0.1:3000"
    exec "$MARTIN_BIN" --postgres "$PG_DSN" \
      --listen-addresses 127.0.0.1:3000
    ;;
  check)
    if [[ "$MARTIN_URL" == "<MARTIN_URL>" ]]; then
      echo "Set MARTIN_URL first." >&2; exit 2
    fi
    curl -fsS "$MARTIN_URL/catalog" | jq .
    ;;
  service)
    cat <<'EOF'
# Windows service sketch (NSSM, fleet pattern) — placeholders only,
# spelling to confirm at validation on the target node:
#   nssm install <SERVICE_NAME> <MARTIN_EXE>
#   nssm set <SERVICE_NAME> AppParameters "--postgres <PG_DSN> --listen-addresses 127.0.0.1:3000"
#   (1.15.0: use the config-file form instead; --postgres rejected)
#   nssm set <SERVICE_NAME> AppStdout <LOG_DIR>\martin.log
#   nssm set <SERVICE_NAME> AppStderr <LOG_DIR>\martin-err.log
#   nssm start <SERVICE_NAME>
# Then re-run: bash deploy.sh check (catalog 200 + sources listed).
EOF
    ;;
  *)
    echo "usage: bash deploy.sh {run|check|service}" >&2
    exit 2
    ;;
esac
