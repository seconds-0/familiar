#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
BACKEND_DIR="$ROOT_DIR/backend"
APP_DIR="$ROOT_DIR/apps/mac/FamiliarApp"
APP_BINARY="$APP_DIR/.build/debug/FamiliarApp"

# Stop any running backend or UI instances quietly
pkill -f "uvicorn palette_sidecar.api" 2>/dev/null || true
pkill -f "FamiliarApp" 2>/dev/null || true

# Ensure the macOS client is built
printf '🛠️  Building FamiliarApp…\n'
(
  cd "$APP_DIR"
  swift build
)

# Relaunch backend with reload enabled
printf '🔥 Starting Familiar sidecar…\n'
(
  cd "$BACKEND_DIR"
  # run in background so the script can continue while logs stream to this shell
  uv run python -m uvicorn palette_sidecar.api:app --host 127.0.0.1 --port 8765 --reload &
)

# Give the backend a moment to boot
sleep 2

# Relaunch the macOS client if the binary exists
if [[ -x "$APP_BINARY" ]]; then
  printf '✨ Launching Familiar app…\n'
  "$APP_BINARY" >/dev/null 2>&1 &
else
  echo "FamiliarApp binary not found at $APP_BINARY even after building." >&2
  exit 1
fi
