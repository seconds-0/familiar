#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
BACKEND_DIR="$ROOT_DIR/backend"
APP_DIR="$ROOT_DIR/apps/mac/FamiliarApp"
APP_BINARY="$APP_DIR/.build/debug/FamiliarApp"

# Optional verbose flag (-v / --verbose)
VERBOSE=0
if [[ $# -gt 0 ]]; then
  case "$1" in
    -v|--verbose)
      VERBOSE=1
      shift
      ;;
  esac
fi

# Stop any running backend or UI instances quietly
pkill -f "uvicorn palette_sidecar.api" 2>/dev/null || true
pkill -f "FamiliarApp" 2>/dev/null || true

# Check if port 8765 is in use and kill any processes using it
if lsof -ti:8765 >/dev/null 2>&1; then
  printf '🧹 Clearing processes using port 8765…\n'
  lsof -ti:8765 | xargs kill -9 2>/dev/null || true
  sleep 0.5  # Give the OS a moment to release the port
fi

# Ensure the macOS client is built
printf '🛠️  Building FamiliarApp…\n'
(
  cd "$APP_DIR"
  swift build
)

printf '🧪 Running Swift tests…\n'
(
  cd "$ROOT_DIR"
  ./test-swift.sh
)

# Relaunch backend with reload enabled
printf '🔥 Starting Familiar sidecar…\n'
(
  cd "$BACKEND_DIR"
  UVICORN_FLAGS=(
    --host 127.0.0.1
    --port 8765
    --reload
  )
  if [[ "$VERBOSE" -eq 1 ]]; then
    printf '   🔎 Verbose logging enabled for sidecar\n'
    UVICORN_FLAGS+=(
      --log-level debug
      --access-log
    )
  fi
  # run in background so the script can continue while logs stream to this shell
  uv run python -m uvicorn palette_sidecar.api:app "${UVICORN_FLAGS[@]}" &
)

# Give the backend a moment to boot
sleep 2

# Open log viewer FIRST (before app launches) to capture startup logs
printf '📋 Opening log viewer in new terminal window…\n'
osascript <<EOF
tell application "Terminal"
    do script "cd '$ROOT_DIR' && ./scripts/watch-logs.sh"
end tell
EOF

# Give log viewer time to start capturing
sleep 1

# Now launch the macOS client
if [[ -x "$APP_BINARY" ]]; then
  printf '✨ Launching Familiar app…\n'
  "$APP_BINARY" &
else
  echo "FamiliarApp binary not found at $APP_BINARY even after building." >&2
  exit 1
fi
