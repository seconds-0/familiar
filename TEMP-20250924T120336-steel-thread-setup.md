# Steel Thread Install & Test Run Guide

## Backend Setup
1. `cd backend`
2. `uv sync`
3. `uv run python -m uvicorn palette_sidecar.api:app --host 127.0.0.1 --port 8765 --reload`
   - Optional: `uv run --with pytest pytest -q`

## macOS Client Build
1. `cd apps/mac/FamiliarApp`
2. `swift build`
3. Launch `.build/debug/FamiliarApp.app` or run `swift run FamiliarApp`

## Configuration Steps
1. Open the menu bar **Familiar** item → **Open Settings…**
2. Add Anthropic API key
3. Choose a workspace folder (creates `.steel-thread-workspace` + demo note)
4. Confirm status banner turns green

## Happy Path Test
1. Summon Familiar (`⌥Space`)
2. Prompt: “Append a note about today’s steel thread demo.”
3. Approve via **Allow Once** and verify transcript + workspace file update
4. Repeat with **Always Allow** to confirm future edits skip approval

## Regression Checks
- Deny a request to ensure the stream halts with an error message
- Point settings to an invalid workspace and confirm validation
- Stop the backend to watch the menu status flip to Offline, then restore

## Packaging Smoke Test (optional)
1. From repo root: `./scripts/steel-thread-package.sh`
2. Review `dist/steel-thread/` contents and `SHA256SUMS`
