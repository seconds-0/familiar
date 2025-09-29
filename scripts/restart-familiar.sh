#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
BACKEND_DIR="$ROOT_DIR/backend"
APP_DIR="$ROOT_DIR/apps/mac/FamiliarApp"
APP_BINARY="$APP_DIR/.build/debug/FamiliarApp"
PORT=8765
MAX_WAIT=10  # Maximum seconds to wait for graceful shutdown

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

# Helper functions for port management
port_in_use() {
    lsof -i ":$PORT" -sTCP:LISTEN >/dev/null 2>&1
}

get_port_pids() {
    lsof -ti ":$PORT" 2>/dev/null || true
}

# Stop any running backend or UI instances with robust cleanup
printf '🛑 Stopping existing processes...\n'

# Stop Mac app first
if pgrep -f "FamiliarApp" >/dev/null 2>&1; then
    printf '   Stopping FamiliarApp...\n'
    pkill -f "FamiliarApp" 2>/dev/null || true
    sleep 1
fi

# Stop backend with graceful shutdown
if port_in_use; then
    PIDS=$(get_port_pids)
    if [ -n "$PIDS" ]; then
        printf '   Stopping backend (PIDs: %s)...\n' "$PIDS"

        # Try graceful shutdown first
        kill $PIDS 2>/dev/null || true

        # Wait for graceful shutdown
        WAITED=0
        while port_in_use && [ $WAITED -lt $MAX_WAIT ]; do
            sleep 1
            WAITED=$((WAITED + 1))
        done

        # Force kill if still running
        if port_in_use; then
            printf '   ⚠️  Graceful shutdown timed out, force killing...\n'
            REMAINING_PIDS=$(get_port_pids)
            if [ -n "$REMAINING_PIDS" ]; then
                kill -9 $REMAINING_PIDS 2>/dev/null || true
                sleep 1
            fi
        fi

        # Final check
        if port_in_use; then
            printf '❌ Error: Unable to free port %s\n' "$PORT" >&2
            lsof -i ":$PORT" >&2
            exit 1
        fi

        printf '   ✅ Backend stopped\n'
    fi
fi

printf '✅ All processes stopped\n\n'

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

# Verify port is free before starting
if port_in_use; then
    printf '❌ Error: Port %s is still in use after cleanup!\n' "$PORT" >&2
    lsof -i ":$PORT" >&2
    exit 1
fi

# Relaunch backend with reload enabled
printf '🔥 Starting Familiar sidecar…\n'
(
  cd "$BACKEND_DIR"
  UVICORN_FLAGS=(
    --host 127.0.0.1
    --port "$PORT"
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

# Relaunch the macOS client if the binary exists
if [[ -x "$APP_BINARY" ]]; then
  printf '✨ Launching Familiar app…\n'
  "$APP_BINARY" >/dev/null 2>&1 &
else
  echo "FamiliarApp binary not found at $APP_BINARY even after building." >&2
  exit 1
fi
