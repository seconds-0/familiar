# Familiar SwiftUI Reference

## Purpose
- **At-a-glance**: Centralizes every SwiftUI note scattered across planning, polish, and architecture docs so contributors can align quickly.
- **Scope**: Covers the current Familiar window, supporting sheets, polish targets, tooling, and future-facing layout explorations.

## Project Overview
- **Summon window**: macOS menu-bar companion summoned with `⌥Space`, streaming Claude responses, collecting approvals, and managing settings.
- **Process model**: SwiftUI front end paired with a FastAPI sidecar that brokers Claude Code SDK sessions, approval hooks, and MCP orchestration.
- **Primary goals**: Keep the palette fast, safe, and delightful—stream tokens instantly, surface permission decisions clearly, and exit without crashes.

## Build & Run Commands
- **SwiftUI app**:
  ```bash
  cd apps/mac/FamiliarApp
  swift build
  open .build/debug/FamiliarApp.app
  ```
- **Backend sidecar**:
  ```bash
  cd backend
  uv sync
  uv run uvicorn palette_sidecar.api:app --host 127.0.0.1 --port 8765 --reload
  ```
- **Steel-thread smoke**: Launch the sidecar, open FamiliarApp, press `⌥Space`, issue a prompt, approve the `PreToolUse` sheet, and verify the “Change applied” card plus file diff.

## Architecture Snapshot
- **Front end responsibilities**: Stream Claude token output, render transcripts, gate tool usage through approval sheets, and expose settings/usage summaries.
- **Repo structure**: `apps/mac/FamiliarApp/` hosts SwiftUI targets with `UI/`, `Services/`, and `Support/` folders; align new files with this layout.
- **Supporting modules**: Menu-bar extra for status + shortcut management, `EventSource` for SSE client, `SidecarClient` for REST interactions, and Keychain helpers for credentials.

## Core Views & Components

### FamiliarView
- **Role**: Fixed 720×460 glass-panel window stacking transcript, tool summary, usage summary, streaming indicator, and composer.
- **Current snapshot**: Monospaced transcript without section dividers; send/stop buttons appear as bordered icons alongside a custom composer footer.
- **Polish focus**: Introduce section dividers or card wrappers, add textual labels (or icon+label capsules) to send/stop controls, and alternate transcript backgrounds or add timestamp chips for readability.
- **Implementation cues**: Update the main `VStack` around lines 90–120 to incorporate `TranscriptEntryView` and label-based buttons with `.controlSize(.large)`.

### PromptTextEditor
- **Role**: Custom `NSTextView` bridge handling focus, placeholder, and preview text for the prompt composer.
- **Current snapshot**: Rounded material background with low-contrast gray stroke, shared styling between placeholder and preview, four-line cap without scrollbar.
- **Polish focus**: Replace stroke with accent-driven semantic color + subtle shadow, italicize preview copy, lighten placeholder, and consider keyboard shortcut cue pills in the footer.
- **Implementation cues**: Apply semantic colors defined in shared style utilities, use `.italic()` + `.foregroundStyle(.quaternary)` for preview, and tune footer microcopy to emphasize Return vs Shift+Return.

### Transcript & Tool Summary
- **Transcript**: Currently a plain stack; add dividers or alternating surfaces, display timestamps, and consolidate summaries into reusable cards.
- **ToolSummaryView**: Swap `.windowBackgroundColor` for a semantic material, add inner padding around diff snippets, and render status as an accent pill (“Applied”, “Error”) instead of icon-only text.
- **UsageSummaryView**: Elevate the “Session” line to a callout, soften “Last session” into caption text, and optionally embed tinted icon circles for sparkles/clock glyphs.

### SettingsView
- **Role**: Credential, model picker, workspace path, and automation toggle management.
- **Current snapshot**: Stack of sections with generous spacing but minimal visual separation; status banner is plain text.
- **Polish focus**: Introduce reusable `SectionCard` styling with padding + background, adopt macOS-style bordered fields, and upgrade status to a tinted `BannerView` with icon + optional link.

### ApprovalSheet
- **Role**: Presents `PreToolUse` approvals with diff preview and Allow/Deny controls.
- **Current snapshot**: 420pt modal with path label, scrollable diff lacking contextual padding, button row using default spacing.
- **Polish focus**: Add metadata row summarizing tool intent, apply colored backgrounds (`green.opacity(0.15)` / `red.opacity(0.15)`) per diff line via `DiffLineView`, and emphasize primary action with `.keyboardShortcut(.defaultAction)` plus descriptive subtitles.

### Menu Bar & Window Controller
- **Menu extra**: Shows sidecar health, houses settings access, and advertises the `⌥Space` summon shortcut.
- **Window behaviour**: Ensure the “Toggle Familiar” menu item simply shows or hides the floating panel without closing the app; guard window actions on the main thread and preserve NSPanel behaviour.

## Interaction Patterns & States
- **Streaming indicator**: Replace inline red labels with a status pill combining progress spinner and short, friendly microcopy anchored above the composer.
- **Loading & errors**: Convert errors into rounded banners with icon + copy; ensure loading microcopy pulls from the curated library in sprint notes.
- **Empty state**: Design dedicated visuals for an empty transcript and settings success confirmations; avoid relying solely on secondary text.
- **Approval decisions**: Keep Allow Once as the default highlighted action, Always Allow as secondary, and provide concise human-readable summaries for each tool request.

## Tooling & Automation
- **Formatting**: `swiftformat apps/mac/FamiliarApp` for code style, `swiftlint lint --path apps/mac/FamiliarApp` for lint checks before submitting polish changes.
- **Visual capture**: Use `ffmpeg`, `gifsicle`, `ImageMagick`, and `shot-scraper` (see `docs/visual-polish-tooling-guide.md`) to document before/after states.
- **Scripts**: `scripts/visual-polish/screenshot-compare.sh`, `create-demo-gif.sh`, and `accessibility-check.sh` output to `visual-diffs/`, `demo-gifs/`, and `accessibility-reports/` for regressions and accessibility sweeps.
- **Git hooks**: Enable the bundled pre-commit unit test hook with `git config core.hooksPath .githooks` so `swift test` runs before every commit.

## QA & Smoke Tests
- **Steel-thread checklist**: Follow `docs/steel-thread.md` to validate install → summon → query → approval → result workflow.
- **Manual QA**: Record gaps or manual verification steps in pull requests and keep `docs/visual-polish-sprint-notes.md` updated until XCTest coverage arrives.

## Future Enhancements
- **Agent sidebar concept**: `AgentSidebarView` and `AgentVisualizationManager` prototypes introduce an HSplitView with expandable agent trees; maintain 200–400pt width bounds and consider lazy stacks for performance.
- **Design tokens & branding**: Plan a follow-up sprint to extract typography scales, semantic colors, and brand accents into reusable tokens feeding both SwiftUI and Style Dictionary pipelines.
- **Motion polish**: Prototype hover, send-button, loading, and approval transitions in Figma Smart Animate or Principle; capture timing specs alongside visuals.

## Related References
- **Strategy**: `docs/prd.md` outlines product scope, architecture, and backend expectations.
- **Polish backlog**: `docs/visual-polish-plan.md` enumerates quick wins vs deeper passes plus component-specific implementation notes.
- **In-flight notes**: `docs/visual-polish-sprint-notes.md` tracks current UI snapshots, rough edges, and open questions.
- **Tooling guide**: `docs/visual-polish-tooling-guide.md` lists install status, acquisition sources, and PATH setup for polish utilities.
- **Collaboration contract**: `AGENTS.md` captures repo organization, build commands, and expectations for SwiftUI contributors.
