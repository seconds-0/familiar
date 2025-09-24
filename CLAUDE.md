# CLAUDE.md

Guidance for Claude Code (claude.ai/code) when working inside this repository.

## Project Overview

This repository designs a **native macOS application** that embeds the Claude Code TypeScript SDK to provide a system-wide command palette, MCP orchestration, and deep filesystem integrations. The end goal is a first-party desktop experience that can spawn processes, manage trust boundaries, and present rich AI-assisted workflows without compromise.

## Current Status

🚧 **Architecture Planning Phase**

Active work involves comparing desktop frameworks, defining IPC boundaries, and documenting product flows. No production-ready source code ships yet; most artifacts live in documentation and tool bundles.

## Collaboration Principles

1. Treat `docs/` as the source of truth for requirements, SDK behaviors, and architectural experiments.
2. Develop the Python sidecar inside `backend/` using `uv` tooling; keep FastAPI endpoints documented and synced with the Swift client.
3. Keep `assets/claude-cli/` intact; it provides the canonical CLI runtime for local validation and should be smoke-tested after dependency changes.
4. Update `AGENTS.md` whenever contributor workflows or security expectations shift so human teammates stay aligned with automated guidance here.
5. Prefer additive planning artifacts (diagrams, ADRs) over speculative code until an architecture option is approved.

## Search & Analysis Tips

- Use targeted `rg` queries or TypeScript-aware tooling to explore the codebase. Avoid wide wildcard searches that inflate context; narrow by directory or file type.
- When investigating SDK behavior, reference `docs/claude-code-sdk.md` before diving into external sources.
- Summarize findings with file paths and line numbers so future contributors can trace decisions quickly.

## Build & Test Expectations

- Backend lives under `backend/`; run `uv run uvicorn palette_sidecar.api:app --host 127.0.0.1 --port 8765 --reload` for local development.
- The Swift client sits under `apps/mac/FamiliarApp/`; resolve dependencies with `swift build` or open `Package.swift` in Xcode for UI iteration.
- Validate `assets/claude-cli/cli.js` with `node assets/claude-cli/cli.js --help` after modifying bundled tooling.
- Propose testing strategies aligned with the chosen stack (e.g., pytest, XCTest) and capture rationale in `docs/prd.md` or a dedicated testing note.

## Architecture Requirements

- Full Claude Code SDK integration, including MCP servers and shell tool execution
- Global hotkey activation with responsive UI overlays
- Fine-grained permission and audit flows for file edits, shell commands, and external services
- Real-time process monitoring with ability to cancel or retry tasks

## Security & Privacy Considerations

- Never commit secrets, API keys, or personal data. Reference secure storage solutions (macOS Keychain, environment variables) when documenting setup steps.
- Document any network access, update mechanisms, or background services in `docs/` so reviewers can evaluate threat surfaces early.

Following these guidelines keeps the project focused on shipping a robust native macOS companion for Claude Code.
