#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
DIST_DIR="$ROOT_DIR/dist/steel-thread"
MAC_APP_DIR="$ROOT_DIR/apps/mac/FamiliarApp"
BACKEND_DIR="$ROOT_DIR/backend"

printf '🔧 Building FamiliarApp in release mode…\n'
swift build --configuration release --package-path "$MAC_APP_DIR"

APP_SOURCE="$MAC_APP_DIR/.build/release/FamiliarApp.app"
if [[ ! -d "$APP_SOURCE" ]]; then
  echo "FamiliarApp.app not found at $APP_SOURCE" >&2
  exit 1
fi

printf '📦 Preparing distribution directory at %s\n' "$DIST_DIR"
rm -rf "$DIST_DIR"
mkdir -p "$DIST_DIR"

cp -R "$APP_SOURCE" "$DIST_DIR/"
rsync -a --exclude='.venv' "$BACKEND_DIR" "$DIST_DIR/"

cat <<NOTE > "$DIST_DIR/README.txt"
Steel Thread distribution (manual installation)
=============================================
1. Install Python 3.11, Node.js >= 18, and the Claude Code CLI:
   npm install -g @anthropic-ai/claude-code
2. From backend/, run: uv sync
3. Launch the sidecar: uv run uvicorn palette_sidecar.api:app --host 127.0.0.1 --port 8765 --reload
4. Open FamiliarApp.app from Finder.
5. Configure API key and workspace in Preferences.
NOTE

printf '✅ Steel Thread bundle staged. Contents:\n'
ls "$DIST_DIR"
