# Steel Thread V1 Checklist

## Onboarding & Install
- [x] Package build script: `scripts/steel-thread-package.sh` stages FamiliarApp.app with backend sidecar
- [x] Health endpoint surfaces missing prerequisites (Node, bundled Claude CLI)
- [x] Settings view captures and persists the Anthropic API key via Keychain
- [x] Workspace selection writes `.steel-thread-workspace` marker and demo note file

## Backend (FastAPI Sidecar)
- [x] Persistent `ClaudeSDKClient` wired with `Write` tool, Sonnet model, and system prompt
- [x] `PreToolUse` hook emits permission requests and waits for UI approval
- [x] Write tool results return path/snippet metadata for the transcript
- [x] `/query`, `/approve`, `/settings`, `/health` expose SSE streaming and control plane

## macOS App (SwiftUI)
- [x] Menu bar extra shows sidecar status and `⌥Space` summon shortcut
- [x] Familiar window streams assistant tokens and supports cancellation
- [x] Approval sheet summarises file edits with Allow Once / Deny actions
- [x] Transcript renders responses plus “change applied” card with diff snippet
- [x] Settings manage API key + workspace with inline status feedback

## QA & Docs
- [x] Steel Thread doc covers install → query → approve → exit
- [x] `docs/steel-thread.md` includes manual smoke test checklist
- [x] README updated with backend/frontend structure and commands

---

## Install Walkthrough

1. **Dependencies**
   ```bash
   brew install python@3.11 node # if not already installed
   npm install -g @anthropic-ai/claude-code
   ```
2. **Sidecar setup**
   ```bash
   cd backend
   uv sync
   uv run uvicorn palette_sidecar.api:app --host 127.0.0.1 --port 8765 --reload
   ```
3. **Mac app build** (development)
   ```bash
   cd apps/mac/FamiliarApp
   swift build
   open .build/debug/FamiliarApp.app
   ```
   For a distributable bundle, run `scripts/steel-thread-package.sh` from the repo root and open `dist/steel-thread/FamiliarApp.app`.
4. **Initial configuration**
   - Open Settings from the menu bar extra.
   - Paste your Anthropic API key and choose a workspace directory.
   - The sidecar marks the folder with `.steel-thread-workspace` and seeds `steel-thread-demo.txt`.

## Smoke Test Checklist

1. Start the sidecar (`uv run uvicorn …`) and confirm `/health` returns `{"status": "ok"}` via the menu bar status.
2. Launch FamiliarApp, press `⌥Space`, and enter a prompt such as:
   > "Append a bullet noting that the steel thread demo ran on $(date)."
3. When the approval sheet appears, verify the target path and preview, then click **Allow Once**.
4. Observe streaming assistant output followed by the “Change applied” card with the snippet from `steel-thread-demo.txt`.
5. Open the workspace file to confirm the appended line matches the summary and that the palette window can be dismissed without lingering dialogs.
