#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
DIST_DIR="$ROOT_DIR/dist/steel-thread"
MAC_APP_DIR="$ROOT_DIR/apps/mac/PaletteApp"
BACKEND_DIR="$ROOT_DIR/backend"

printf '🔧 Building PaletteApp in release mode…\n'
swift build --configuration release --package-path "$MAC_APP_DIR"

APP_SOURCE=$(find "$MAC_APP_DIR/.build/release" -maxdepth 1 -name 'PaletteApp*.app' -print -quit)
APP_BINARY="$MAC_APP_DIR/.build/release/PaletteApp"
if [[ -z "$APP_SOURCE" ]]; then
  if [[ ! -x "$APP_BINARY" ]]; then
    echo "PaletteApp binary not found. Run swift build manually and retry." >&2
    exit 1
  fi
  APP_SOURCE=""
else
  APP_BINARY=""
fi

printf '📦 Preparing distribution directory at %s\n' "$DIST_DIR"
rm -rf "$DIST_DIR"
mkdir -p "$DIST_DIR"

if [[ -n "$APP_SOURCE" ]]; then
  cp -R "$APP_SOURCE" "$DIST_DIR/"
else
  BUNDLE_DIR="$DIST_DIR/PaletteApp.app"
  printf '🧱 Constructing minimal app bundle at %s\n' "$BUNDLE_DIR"
  mkdir -p "$BUNDLE_DIR/Contents/MacOS"
  cp "$APP_BINARY" "$BUNDLE_DIR/Contents/MacOS/PaletteApp"
  chmod +x "$BUNDLE_DIR/Contents/MacOS/PaletteApp"
  cat <<'PLIST' > "$BUNDLE_DIR/Contents/Info.plist"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleName</key>
  <string>PaletteApp</string>
  <key>CFBundleExecutable</key>
  <string>PaletteApp</string>
  <key>CFBundleIdentifier</key>
  <string>com.palette.steelthread</string>
  <key>CFBundlePackageType</key>
  <string>APPL</string>
  <key>CFBundleVersion</key>
  <string>1.0</string>
  <key>CFBundleShortVersionString</key>
  <string>1.0</string>
  <key>NSPrincipalClass</key>
  <string>NSApplication</string>
</dict>
</plist>
PLIST
fi
rsync -a --exclude='.venv' "$BACKEND_DIR" "$DIST_DIR/"

cat <<NOTE > "$DIST_DIR/README.txt"
Steel Thread distribution (manual installation)
=============================================
1. Install Python 3.11, Node.js >= 18, and the Claude Code CLI:
   npm install -g @anthropic-ai/claude-code
2. From backend/, run: uv sync
3. Launch the sidecar: uv run uvicorn palette_sidecar.api:app --host 127.0.0.1 --port 8765 --reload
4. Open PaletteApp.app from Finder.
5. Configure API key and workspace in Preferences.
NOTE

cat <<'NOTARIZE' > "$DIST_DIR/NOTARIZATION_STUB.txt"
Notarization Placeholder
========================
1. Zip the PaletteApp bundle for submission:
   ditto -c -k --keepParent PaletteApp.app PaletteApp.zip
2. Submit to Apple notarization once credentials and App Store Connect API key
   are available:
   xcrun notarytool submit PaletteApp.zip --key YOUR_KEY.p8 \
       --key-id YOUR_KEY_ID --issuer YOUR_ISSUER_ID --wait
3. Staple the ticket to the app bundle after approval:
   xcrun stapler staple PaletteApp.app

Until credentials are configured in CI, this file acts as a reminder and
documentation stub for the notarization pipeline.
NOTARIZE

(
  cd "$DIST_DIR"
  find . -type f ! -name 'SHA256SUMS' -print0 | LC_ALL=C sort -z | xargs -0 -I {} shasum -a 256 "{}" > SHA256SUMS
)

printf '✅ Steel Thread bundle staged. Contents:\n'
ls "$DIST_DIR"
