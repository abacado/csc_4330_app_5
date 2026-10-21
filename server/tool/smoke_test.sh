#!/usr/bin/env bash
# Starts the real server, saves a listing, restarts the server, and checks the
# listing is still there. Run from the server/ folder: bash tool/smoke_test.sh
set -euo pipefail

PORT="${PORT:-8181}"
BASE="http://127.0.0.1:$PORT"
DATA="$(mktemp -d)/smoke.json"
PID=""

start() {
  dart run bin/server.dart --port "$PORT" --data "$DATA" > /tmp/hobbyswap-smoke.log 2>&1 &
  PID=$!
  for _ in $(seq 1 60); do
    curl -sf "$BASE/health" > /dev/null && return 0
    sleep 0.5
  done
  echo "Server did not start:"; cat /tmp/hobbyswap-smoke.log; exit 1
}

stop() {
  kill -TERM "$PID" 2>/dev/null || true
  wait "$PID" 2>/dev/null || true
}
trap stop EXIT

start
ID=$(curl -sf -X POST "$BASE/listings" -H 'Content-Type: application/json' \
  -d '{"ownerId":"smoke","hobbyId":"painting","title":"Smoke test easel","description":"CI check","condition":"Good","type":"giveaway"}' \
  | sed -E 's/.*"id":"([^"]+)".*/\1/')
echo "Created listing $ID"
stop

start
if curl -sf "$BASE/listings/$ID" | grep -q '"Smoke test easel"'; then
  echo "✅ Listing $ID survived a server restart"
else
  echo "❌ Listing $ID was lost after restart"; exit 1
fi
