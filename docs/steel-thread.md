# Steel Thread V1 Checklist

## Onboarding & Install
- [ ] Package macOS app bundle with sidecar launcher (DMG or signed zip)
- [ ] Detect or install Claude Code CLI / Node prerequisites
- [ ] Capture Anthropic API key via onboarding flow
- [ ] Select demo workspace directory and persist `.steel-thread-workspace`

## Backend (FastAPI Sidecar)
- [ ] Persistent ClaudeSDKClient with allowed `Write` tool and hard-coded model
- [ ] PreToolUse hook sends permission request to UI and waits for decision
- [ ] Approved tool appends to demo file and returns ToolResultBlock summary
- [ ] `/query`, `/approve`, `/health` endpoints serve SSE responses and permission actions

## macOS App (SwiftUI)
- [ ] Menu bar app shows sidecar status and exposes `⌥Space` summon shortcut
- [ ] Palette window streams assistant tokens within 1s perceived latency
- [ ] Approval sheet summarises file change, supports Allow Once / Deny
- [ ] Transcript displays final answer + “change applied” card with file path snippet
- [ ] Settings view manages API key + workspace, verifies connection

## QA & Docs
- [ ] Write README/steel-thread guide covering install → query → approve → exit
- [ ] Provide smoke test script/checklist for Steel Thread validation
- [ ] Document limitations and next steps for Phase 2
