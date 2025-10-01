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
4. Observe streaming assistant output followed by the "Change applied" card with the snippet from `steel-thread-demo.txt`.
5. Open the workspace file to confirm the appended line matches the summary and that the palette window can be dismissed without lingering dialogs.

### Context Performance Validation

These tests ensure context engineering best practices are working:

**Test 1: Large File Handling**
1. Create a test file with 100,000+ characters in your workspace
2. Ask: "What's in large-test-file.txt?"
3. Verify the response shows a truncated preview with "... [N more characters]" note
4. Confirm Claude didn't load the entire file into context immediately

**Test 2: Directory Listing**
1. Create a directory with 100+ files
2. Ask: "What files are in test-directory/?"
3. Verify response shows metadata (names, sizes, dates) not file contents
4. Confirm response includes note like "Use read_file(path) for specific contents"

**Test 3: Metadata-First Responses**
1. Ask: "List all files in my workspace"
2. Verify backend returns JSON with `summary` field and file metadata
3. Confirm no file contents are loaded unless explicitly requested
4. Check backend logs—context size should be < 5K tokens for typical workspace

**Test 4: Context Budget Enforcement**
1. Check `backend/src/palette_sidecar/config.py` constants are defined:
   - `MAX_FILE_PREVIEW_SIZE = 1000`
   - `MAX_SEARCH_RESULTS = 20`
   - `MAX_DIRECTORY_LISTING = 50`
2. Verify these limits are enforced in tool responses
3. Test with inputs exceeding limits—should truncate gracefully

**Test 5: Token Usage Monitoring** (when measure-context.py is available)
```bash
cd backend
uv run python scripts/measure-context.py --prompt "Organize my desktop files"
```
Expected: < 10K tokens for typical Steel Thread interaction

**Success Criteria**:
- File previews truncate at ~1000 characters with expansion note
- Directory listings show metadata, not contents
- Large operations remain under 10K total tokens
- No context explosion with 100+ files or 100K+ character files

## Canonical Walkthrough

- Capture a short Loom (<=2 minutes) that demonstrates: launch, health indicator, diff-based approval, "Always Allow", and the quick-open shortcuts from the menu bar.
- Store the recording in the shared assets bucket and drop the link below once available:
  - Loom link: _TBD_
- Add two screenshots to `docs/images/` when ready:
  1. Approval sheet rendering a multi-line diff preview.
  2. Menu bar extra with workspace/demo quick-open buttons.

## Troubleshooting

### Missing Node.js Runtime

- Run `node --version`; install via `brew install node` if the command fails.
- Verify the bundled CLI is reachable: `node assets/claude-cli/cli.js --help`.

### Anthropic API Key Not Detected

- Open **Palette -> Open Settings...** and re-enter the key; the status banner should turn green after saving.
- Confirm the macOS Keychain entry `anthropic_api_key` exists and is not locked.

### Workspace or CLI Path Errors

- Ensure the selected workspace contains `.steel-thread-workspace`; rerun the setup to recreate it if missing.
- Inspect the CLI path exported by the sidecar via `echo $CLAUDE_CODE_CLI_PATH` in the packaged environment; it should point to `assets/claude-cli/cli.js`.

### Permission Flow Hints

- Diff previews now render unified diffs; scroll to review multi-line edits before approving.
- Use **Always Allow** when you trust a file path - the decision is stored per tool in `~/.palette-app/config.json` and auto-applies on future runs.
- Denied requests immediately stop the active stream and surface a localized error so the user can retry with adjusted context.

## Sample Prompts

1. `Summarise the TODOs from steel-thread-demo.txt and append a next-step bullet.`
2. `Replace the introduction in steel-thread-demo.txt with a two-line summary of today's session.`
3. `List the files in the workspace and propose a cleanup plan; do not edit anything yet.`
