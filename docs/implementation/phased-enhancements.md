# Phased Enhancements - Roadmap for Familiar

**Status**: 📋 PLANNED
**Purpose**: Systematic improvements to UX, Claude SDK utilization, and visual design

---

## Overview

This document outlines 4 phases of enhancements to transform Familiar from a functional prototype into a polished, delightful product. Each phase builds on the previous, with clear goals, implementation steps, and success criteria.

**Timeline**: 10-12 weeks total
**Priority**: Start with Phase 1, validate with users, then proceed

---

## Phase 1: Claude Login Polish (1 week)

### Goal

Make the Claude.ai authentication flow intuitive, transparent, and error-proof.

### Current Pain Points

- Button states are binary (enabled/disabled) - no intermediate feedback
- Browser launch is silent - users don't know what happened
- Errors are generic - no actionable guidance
- No security indicators - users may hesitate to trust the URL
- Success feels abrupt - no celebration or confirmation

### Improvements

#### 1.1 Visual State Machine for Login Button

**Current**: Simple enabled/disabled toggle
**Improved**: Rich state representation

```swift
enum ClaudeLoginState: Equatable {
    case notAuthenticated               // "Sign In" button, blue accent
    case initiating                     // "Opening browser..." with spinner
    case waitingForUser(URL)            // "Complete sign-in" with URL domain shown
    case verifying                      // "Verifying..." with spinner
    case authenticated(account: String) // Checkmark + "Signed in as {email}"
    case error(message: String)         // Warning icon + "Retry" button
}
```

**Implementation**:

- Extract state logic from `SettingsView.swift:312-334` to dedicated view model
- Add state-specific button styling and labels
- Smooth transitions with `.animation(.familiarEaseInOut)`

**Files to modify**: `SettingsView.swift:162-202`

#### 1.2 Manual URL Copy Fallback

**Problem**: If browser doesn't auto-launch, user is stuck
**Solution**: "Didn't open? Copy URL" button

```swift
if case .waitingForUser(let url) = loginState {
    Button("Copy Login URL") {
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(url.absoluteString, forType: .string)
        // Show toast: "Copied! Paste in your browser"
    }
    .buttonStyle(.borderless)
    .foregroundStyle(.secondary)
}
```

**Backend enhancement**: Return `loginUrl` in initial response (already implemented)

#### 1.3 Browser Domain Security Indicator

**Problem**: Users may hesitate - "Is this phishing?"
**Solution**: Show trusted domain before launch

```swift
HStack(spacing: 4) {
    Image(systemName: "lock.shield")
        .foregroundStyle(.green)
    Text("Redirecting to api.claude.ai...")
        .font(.caption)
        .foregroundStyle(.secondary)
}
```

**Rationale**: Transparency builds trust. Show the domain, explain it's official.

#### 1.4 Success Animation + Haptic Feedback

**Problem**: Login completes silently
**Solution**: Celebration moment

```swift
// On successful authentication
withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
    // Scale checkmark from 0.5 to 1.2, then settle at 1.0
    checkmarkScale = 1.2
}

// Haptic feedback (if supported)
NSHapticFeedbackManager.defaultPerformer.perform(
    .alignment,
    performanceTime: .default
)

// Auto-dismiss settings after 2s (optional)
DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
    // closeSettings()
}
```

**Files to modify**: `SettingsView.swift:320-328`

#### 1.5 Improved Error Messages with Actions

**Current**: `"Login failed: {technical error}"`
**Improved**: Contextual, actionable guidance

```swift
enum LoginError {
    case timeout
    case networkFailure
    case cliUnavailable
    case canceled

    var userMessage: String {
        switch self {
        case .timeout:
            return "Login took too long. Check your internet and try again."
        case .networkFailure:
            return "Couldn't reach Claude.ai. Verify your connection."
        case .cliUnavailable:
            return "Claude CLI missing. Please reinstall Familiar."
        case .canceled:
            return "Login canceled. Click Sign In to try again."
        }
    }

    var recoveryAction: String? {
        switch self {
        case .timeout, .networkFailure:
            return "Retry"
        case .cliUnavailable:
            return "Get Help"
        case .canceled:
            return nil
        }
    }
}
```

**Files to modify**: `SettingsView.swift:329-333`, `claude_service.py:307-320`

---

### Phase 1 Success Criteria

- [ ] User can understand current state at a glance (no ambiguity)
- [ ] Browser launch is explained with domain shown
- [ ] Manual URL copy works as backup
- [ ] Success feels rewarding (animation + haptic)
- [ ] Errors provide clear next steps
- [ ] Zero confusion in user testing (5/5 users complete login successfully)

---

### Phase 1 Implementation Checklist

**Backend (Python)**:

- [ ] Ensure `loginUrl` is returned in all auth responses
- [ ] Add structured error types with user-friendly messages
- [ ] Improve CLI output parsing reliability

**Frontend (SwiftUI)**:

- [ ] Create `ClaudeLoginState` enum and view model
- [ ] Implement state machine UI with proper transitions
- [ ] Add "Copy URL" fallback button
- [ ] Create `SecurityIndicatorView` showing domain
- [ ] Implement success animation with haptic feedback
- [ ] Add `LoginErrorView` with contextual messages

**Testing**:

- [ ] Unit test state machine transitions
- [ ] Manual QA with slow network
- [ ] Manual QA with browser not installed
- [ ] Manual QA with firewall blocking
- [ ] Verify haptic feedback on supported hardware

---

## Phase 2: Settings UX Overhaul (2 weeks)

### Goal

Transform settings from cramped form into intuitive, guided experience.

### Improvements

#### 2.1 First-Run Onboarding Wizard

**Concept**: Multi-step guided flow instead of overwhelming single screen

```
Step 1: Welcome
┌─────────────────────────────────────┐
│  Welcome to Familiar!               │
│                                     │
│  [Illustration: Command palette]    │
│                                     │
│  Let's get you set up...            │
│                                     │
│         [Continue →]                │
└─────────────────────────────────────┘

Step 2: Choose Authentication
┌─────────────────────────────────────┐
│  How would you like to connect?     │
│                                     │
│  ○ Claude.ai Login (Recommended)    │
│    No API key needed                │
│    [Sign In]                        │
│                                     │
│  ○ API Key                          │
│    For advanced users               │
│    [Enter Key]                      │
│                                     │
│         [Back] [Continue →]         │
└─────────────────────────────────────┘

Step 3: Select Workspace
┌─────────────────────────────────────┐
│  Choose your workspace              │
│                                     │
│  /Users/alex/projects/my-app        │
│  [Browse...]                        │
│                                     │
│  ℹ️  Familiar will work within      │
│     this directory                  │
│                                     │
│         [Back] [Finish]             │
└─────────────────────────────────────┘
```

**Implementation**:

- Create `OnboardingFlow` view with `@State var currentStep: Step`
- Only show on first launch (check `UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")`)
- Allow skipping to settings for advanced users

#### 2.2 Auth Method Comparison Table

**Problem**: Users don't understand trade-offs
**Solution**: Side-by-side comparison

| Feature    | Claude.ai Login    | API Key             |
| ---------- | ------------------ | ------------------- |
| Setup Time | 30 seconds         | 2 minutes           |
| Cost       | Free with Max plan | Pay-per-use         |
| Management | Automatic          | Manual rotation     |
| Best For   | Most users         | Advanced/enterprise |

**Visual Treatment**: Cards with icons, not just text table

#### 2.3 Empty State Illustrations

**Current**: Blank fields, no guidance
**Improved**: Friendly illustrations explaining each section

```swift
// When API key is empty
VStack(spacing: 12) {
    Image(systemName: "key.fill")
        .font(.system(size: 48))
        .foregroundStyle(.secondary)
    Text("No API key configured")
        .font(.headline)
    Text("Enter your Anthropic API key to get started")
        .font(.subheadline)
        .foregroundStyle(.secondary)
        .multilineTextAlignment(.center)
    Button("Get an API Key") {
        NSWorkspace.shared.open(URL(string: "https://console.anthropic.com")!)
    }
}
.padding(.vertical, 32)
```

#### 2.4 Inline Help Tooltips

**Problem**: Users don't understand workspace concept
**Solution**: Contextual help icons

```swift
HStack {
    Text("Workspace")
        .font(.headline)
    Button {
        showWorkspaceHelp = true
    } label: {
        Image(systemName: "questionmark.circle")
            .foregroundStyle(.secondary)
    }
    .buttonStyle(.borderless)
    .popover(isPresented: $showWorkspaceHelp) {
        VStack(alignment: .leading, spacing: 8) {
            Text("What's a workspace?")
                .font(.headline)
            Text("The folder where Familiar can read and write files. For safety, Familiar only works within this directory.")
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(width: 280)
    }
}
```

#### 2.5 Settings Validation Feedback

**Current**: Settings save silently or show generic error
**Improved**: Real-time validation with helpful hints

```swift
// Example: API key validation
TextField("sk-ant-...", text: $apiKey)
    .onChange(of: apiKey) { newValue in
        if !newValue.isEmpty {
            validateApiKey(newValue)
        }
    }

if case .invalid(let reason) = apiKeyValidation {
    Label(reason, systemImage: "exclamationmark.triangle")
        .foregroundStyle(.orange)
        .font(.caption)
}

func validateApiKey(_ key: String) {
    if !key.hasPrefix("sk-ant-") {
        apiKeyValidation = .invalid("API keys start with 'sk-ant-'")
    } else if key.count < 40 {
        apiKeyValidation = .invalid("Key seems too short")
    } else {
        apiKeyValidation = .valid
    }
}
```

---

### Phase 2 Success Criteria

- [ ] First-run experience is welcoming, not overwhelming
- [ ] Users understand auth method trade-offs before choosing
- [ ] Empty states provide clear next steps
- [ ] Inline help reduces support questions
- [ ] Validation catches mistakes before saving

---

## Phase 3: SDK Feature Exposure (3 weeks)

### Goal

Surface powerful Claude Agent SDK features through intuitive UI.

### 3.1 Slash Commands Autocomplete

**SDK Feature**: Custom commands from `.claude/commands` directory
**UI Implementation**: Autocomplete dropdown

```swift
// In PromptTextEditor
if prompt.hasPrefix("/") {
    SlashCommandPicker(
        commands: availableCommands,
        filter: String(prompt.dropFirst()),
        onSelect: { command in
            prompt = "/\(command.name) "
            focusPrompt()
        }
    )
    .frame(maxHeight: 200)
    .background(Material.thick)
    .cornerRadius(8)
    .shadow(radius: 8)
}
```

**Backend**: Add `/commands` endpoint to list available commands

**Example Commands**:

- `/review` - Code review current file
- `/test` - Generate tests for selection
- `/explain` - Explain complex code
- `/refactor` - Suggest refactoring

#### 3.2 CLAUDE.md Memory Viewer/Editor

**SDK Feature**: Project memory stored in `CLAUDE.md`
**UI Implementation**: In-app editor with syntax highlighting

```
Settings → Memory tab
┌────────────────────────────────────┐
│ Project Memory (CLAUDE.md)         │
│                                    │
│ [Edit] [Refresh] [History]        │
│                                    │
│ # Project Context                  │
│ This is a FastAPI + SwiftUI app... │
│                                    │
│ ## Architecture                    │
│ - Backend: Python sidecar          │
│ - Frontend: Native macOS           │
│                                    │
└────────────────────────────────────┘
```

**Features**:

- Live preview of how Claude sees the memory
- Templates for common memory structures
- Undo/redo with version history
- Validate markdown syntax

#### 3.3 Cost Tracking with Budget Alerts

**SDK Feature**: Usage and cost data in result messages
**UI Implementation**: Budget dashboard

```swift
struct CostDashboardView: View {
    @ObservedObject var costTracker: CostTracker

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Monthly budget progress
            HStack {
                Text("Budget")
                    .font(.headline)
                Spacer()
                Text("$\(costTracker.spent, specifier: "%.2f") / $\(costTracker.budget, specifier: "%.2f")")
                    .foregroundStyle(costTracker.isNearLimit ? .orange : .secondary)
            }

            ProgressView(value: costTracker.percentUsed)
                .tint(costTracker.isNearLimit ? .orange : .accentColor)

            // Cost breakdown
            ForEach(costTracker.dailyCosts) { day in
                HStack {
                    Text(day.date, style: .date)
                        .font(.caption)
                    Spacer()
                    Text("$\(day.amount, specifier: "%.2f")")
                        .font(.caption.monospacedDigit())
                }
            }

            // Set budget
            HStack {
                Text("Monthly Budget")
                TextField("$", value: $costTracker.budget, format: .currency(code: "USD"))
                    .textFieldStyle(.roundedBorder)
                    .frame(width: 100)
            }

            Toggle("Alert at 80%", isOn: $costTracker.alertEnabled)
        }
        .cardStyle()
    }
}
```

**Persistence**: Store budget and history in `UserDefaults` or sidecar settings

#### 3.4 MCP Server Marketplace UI

**SDK Feature**: MCP server configuration from `.mcp.json`
**UI Implementation**: Browsable gallery with one-click install

```
Settings → Integrations tab
┌────────────────────────────────────┐
│ Available MCP Servers              │
│                                    │
│ 🔍 Search servers...               │
│                                    │
│ ┌──────────────────────────────┐  │
│ │ 📂 Filesystem                 │  │
│ │ Read and write files          │  │
│ │ [✓ Installed] [Configure]    │  │
│ └──────────────────────────────┘  │
│                                    │
│ ┌──────────────────────────────┐  │
│ │ 🐙 GitHub                     │  │
│ │ Issues, PRs, and repos        │  │
│ │ [Install] [Learn More]       │  │
│ └──────────────────────────────┘  │
│                                    │
│ ┌──────────────────────────────┐  │
│ │ 🔐 1Password                  │  │
│ │ Secure credential access      │  │
│ │ [Install]                    │  │
│ └──────────────────────────────┘  │
└────────────────────────────────────┘
```

**Backend**:

- Serve curated MCP registry from JSON file
- Handle installation (npm/pip/binary)
- Manage `.mcp.json` updates
- Validate server health post-install

#### 3.5 Tool Execution History Viewer

**SDK Feature**: Tool use/result events
**UI Implementation**: Expandable timeline

```swift
struct ToolHistoryView: View {
    @ObservedObject var history: ToolExecutionHistory

    var body: some View {
        List(history.executions) { execution in
            DisclosureGroup {
                VStack(alignment: .leading, spacing: 8) {
                    // Tool input
                    Text("Input:")
                        .font(.caption.bold())
                    Text(execution.input)
                        .font(.caption.monospaced())
                        .padding(8)
                        .background(Color.secondary.opacity(0.1))
                        .cornerRadius(4)

                    // Tool output
                    Text("Output:")
                        .font(.caption.bold())
                    Text(execution.output)
                        .font(.caption.monospaced())
                        .padding(8)
                        .background(Color.secondary.opacity(0.1))
                        .cornerRadius(4)

                    // Metadata
                    HStack {
                        Label("\(execution.duration)ms", systemImage: "clock")
                        Label(execution.status, systemImage: execution.statusIcon)
                    }
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                }
            } label: {
                HStack {
                    Image(systemName: execution.icon)
                        .foregroundStyle(execution.statusColor)
                    VStack(alignment: .leading) {
                        Text(execution.toolName)
                            .font(.headline)
                        Text(execution.timestamp, style: .relative)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Text(execution.status)
                        .font(.caption)
                        .foregroundStyle(execution.statusColor)
                }
            }
        }
    }
}
```

---

### Phase 3 Success Criteria

- [ ] Slash commands discoverable and easy to invoke
- [ ] Memory editing improves context quality
- [ ] Cost tracking prevents surprise bills
- [ ] MCP installation is one-click simple
- [ ] Tool history aids debugging and learning

---

## Phase 4: Agent Visualization (4 weeks)

### Goal

Transform Claude Code's invisible agent orchestration into transparent, delightful experience.

**See**: `docs/design/agent-visualization.md` for complete specification

### Highlights

#### 4.1 Right Sidebar Architecture

- Resizable sidebar (200-400px) showing active agents
- HSplitView layout expanding main window
- Collapsible to icon-only mode

#### 4.2 Deterministic Sigil System

- SHA1-based visual anchors for sessions/tools
- Consistent glyphs from seed: `session_id|prompt|path|tool_name`
- Rendered on Canvas for performance

#### 4.3 Magical Animations

- **Spawning**: Particle burst as agent materializes (0.8s)
- **Working**: Golden pulsing with 2s breath cycle
- **Completion**: Green sparkle burst
- Respects `prefersReducedMotion`

#### 4.4 Haiku-Powered Status Summaries

- Real-time "Seeking patterns..." style descriptions
- Cost: ~$0.0001 per summary (sustainable)
- Fallback to templates on API failure

#### 4.5 Agent Hierarchy Tree

- Parent/child relationships visualized
- Indentation and connecting lines
- Click to expand details

---

### Phase 4 Success Criteria

- [ ] Sidebar performs at 60fps with 10+ active agents
- [ ] Users understand what's happening during complex requests
- [ ] Animations delight without distracting
- [ ] Cost stays under $0.02 per typical session
- [ ] Accessibility: VoiceOver describes agent activity

---

## Cross-Phase Considerations

### Code Simplification Targets


---

# Detailed Plan (All Phases)

The sections below expand each phase with concrete deliverables, API/UI specs, acceptance criteria, validation plans, risks, dependencies, estimates, and rollout notes. Use these as implementation checklists and PR planning guides.

## Phase 1 — Claude Login Polish (1 week)

### Deliverables
- Frontend: `ClaudeLoginState` enum and a dedicated login view model driving `ClaudeLoginSection`
- Frontend: Security indicator showing trusted domain before/while redirecting
- Frontend: “Copy Login URL” fallback with toast feedback and VoiceOver label
- Frontend: Success animation (Familiar Spring) and haptic on auth completion
- Frontend: Error display that maps technical failures to conversational guidance with recovery actions
- Backend: Ensure `loginUrl` present whenever available; maintain current JSON contract (`active`, `account`, `message`, `pending`, `loginUrl`)
- Backend: Normalize common auth error messages (timeout, CLI unavailable) to be user-friendly without leaking internals

### Tasks by Track
- Backend
  - Confirm `_auth_response` always forwards `loginUrl` when present (done)
  - Add message normalization helpers in `auth_coordinator.py` for common failures (timeout, CLI missing)
  - Ensure pending state is consistently set during CLI login; keep message non-empty during pending
  - Tests: extend `test_auth_endpoints.py` to assert `loginUrl` passthrough and friendly messages
- Frontend
  - Add `ClaudeLoginState` with states: `notAuthenticated`, `initiating`, `waitingForUser(URL)`, `verifying`, `authenticated(account)`, `error(message)`
  - Extract state transitions into `SettingsViewModel` (or a focused `LoginStateModel`)
  - Update `ClaudeLoginSection` to render by state (labels, spinners, icons) with `.animation(.familiar)`
  - Add security indicator (lock + “api.claude.ai”) and conditionally show when state is `.waitingForUser`
  - Add “Copy Login URL” button (uses `NSPasteboard`) and non-blocking toast: “Copied! Paste in your browser”
  - Add success haptic via `NSHapticFeedbackManager`; respect `prefersReducedMotion`
  - Map error messages from backend to conversational strings with optional primary action (e.g., Retry, Get Help)
  - Wire polling loop to move from `waitingForUser` → `verifying` → `authenticated|error`
- Docs
  - Update `docs/design/visual-improvements.md` with screenshots of states
  - Note error copy in `docs/design/aesthetic-system.md` Language section

### API/UI Spec
- API stays stable: `GET /auth/claude/status`, `POST /auth/claude/login`, `POST /auth/claude/logout`
- Response fields used by UI: `active:boolean`, `account:string|null`, `pending:boolean`, `message?:string`, `loginUrl?:string`
- UI states and triggers:
  - Click “Sign In” → `.initiating` → backend `login` → set `.waitingForUser(url)` when `loginUrl` present
  - Background poll every 1s up to 120s; switch to `.verifying` on status change, then finalize

### Acceptance Criteria
- Visual indicator of login state is always present and unambiguous
- Security domain visible before launching browser or copying link
- “Copy Login URL” copies the exact value from backend and shows confirmation
- On success, haptic fires (supported hardware) and a brief celebratory animation runs; respects reduced motion
- Errors show conversational copy and provide a clear next step

### Validation & QA
- Unit tests: view-model state transitions and copy action invoked; backend tests for message normalization
- Manual scenarios: slow network, default browser missing, CLI missing, intermittent CLI output, firewall blocks
- Accessibility: VoiceOver reads state label; tab navigation reaches “Copy URL”; color contrast meets minimums

### Risks & Mitigations
- CLI output variability → Already handled via JSON/text fallbacks; keep tests mirroring both paths
- Browser open fails → Surface “Copy URL” prominently; never block on open
- Over-animating → Respect `.accessibilityReduceMotion` and keep animation brief

### Estimate & Rollout
- Estimate: 3–4 days frontend, 1–2 days backend + tests
- Rollout: ship behind a lightweight preference key `LoginPolishEnabled` defaulting true; revert path is to show current static UI

---

## Phase 2 — Settings UX Overhaul (2 weeks)

### Deliverables
- First-run `OnboardingFlow` with 3 steps (Welcome → Auth choice → Workspace selection), gated by `hasCompletedOnboarding`
- Auth comparison cards clarifying trade-offs (Claude Login vs API Key)
- Empty-state illustrations and helper text for unconfigured sections
- Inline help tooltip/popover for “Workspace” concept
- Real-time validation for API key field (prefix, length heuristics); non-blocking hints

### Tasks by Track
- Frontend
  - Build `OnboardingFlow` view; persist completion via `UserDefaults`
  - Add comparison cards using design tokens; include “Learn more” links
  - Add popover help for workspace with clear, conversational copy
  - Add API key validation and inline feedback (uses pattern rules only client-side)
  - Update `SettingsView` layout spacing to 8pt grid; ensure consistent typography
- Backend
  - No new endpoints required; ensure `/settings` gracefully handles missing workspace by returning `defaultWorkspace`
- Docs
  - Document onboarding skip/restore steps in README and `docs/00-README.md`

### Acceptance Criteria
- First launch opens onboarding automatically; subsequent launches do not
- Users can switch auth methods during onboarding without losing progress
- Empty states provide a clear CTA; validation fires as the user types
- All UI respects 8pt grid, uses Familiar tokens, and passes Language Test

### Validation & QA
- Manual: fresh install flow, switching auth methods mid-flow, selecting invalid workspace, reduced motion enabled
- Accessibility: VoiceOver step labels, focus order, popover dismissibility, keyboard navigation

### Risks & Mitigations
- Users stuck in onboarding → Provide “Skip for now” and “Open Settings” options
- Validation false positives → Keep checks advisory (non-blocking) and conversational

### Estimate & Rollout
- Estimate: ~8–10 days frontend polish + iterations
- Rollout: feature-guard onboarding with `OnboardingEnabled`; fallback to current Settings

---

## Phase 3 — SDK Feature Exposure (3 weeks)

### Deliverables
- Slash commands autocomplete in `PromptTextEditor` for `.claude/commands`
- Backend `GET /commands` endpoint (metadata-first; respects MAX_* limits)
- In-app `CLAUDE.md` memory viewer/editor with preview and history templates
- Cost dashboard with budget setting and 80% alert; persisted in settings
- MCP server gallery (read-only list first), with install/config flows planned
- Tool execution history viewer (recent N) with input/output previews and metadata

### API/UI Spec
- `GET /commands` → `{ summary, commands: [{ name, description, path? }] }` (no file contents)
- `GET /memory` → `{ preview, totalChars }` truncated to `MAX_FILE_PREVIEW_SIZE`; `PUT /memory` to save changes
- `GET /usage/costs` → `{ totals, daily }` for dashboard
- `GET /mcp/registry` → curated JSON from assets; `GET /mcp/status`; (future) `POST /mcp/install`
- `GET /tools/history?limit=50` → recent tool events with metadata-only snippets

### Tasks by Track
- Backend
  - Implement `/commands` with directory scan of `.claude/commands` and metadata-first payload
  - Add memory preview/save with size enforcement and newline-preserving writes
  - Expose usage totals accumulator (session + daily) and simple in-memory ring buffer for tool history
  - Serve MCP registry JSON from assets and health summaries per server
- Frontend
  - `PromptTextEditor`: when `/` typed, show picker with filtered commands; on select insert `/<name> `
  - Settings → Memory tab with editor, preview, “History” placeholder and templates
  - Cost dashboard card with budget input and alert toggle
  - Integrations tab: MCP gallery cards (Install/Configure disabled until Phase 3.4 backend ready)
  - Tool History view with disclosure rows (input/output previews are monospaced, truncated)

### Acceptance Criteria
- Slash commands discoverable with keyboard; insert is instant and keeps focus
- Memory tab edits persist; previews reflect truncation affordance
- Budget dashboard shows totals; alert visually distinct at threshold
- MCP gallery lists known servers and shows installed status
- Tool history displays recent actions with durations and status colors

### Validation & QA
- Large repos: `.claude/commands` with 100+ files still returns within limits
- Memory file >1000 chars shows preview + “[N total chars…]” affordance
- Cost values stable across windows; currency formatting correct
- Accessibility: picker is navigable; history details are readable with VoiceOver

### Risks & Mitigations
- Context explosion → Enforce `MAX_*` constants on all endpoints
- MCP install security → Defer install execution to a later milestone; start with read-only registry

### Estimate & Rollout
- Estimate: ~10–12 days across backend/frontend
- Rollout: land endpoints gated; UI surfaces features progressively (tabs visible but non-blocking)

---

## Phase 4 — Agent Visualization (4 weeks)

### Deliverables
- Right sidebar showing active agents; resizable; collapsible to icons
- Deterministic sigils (SHA1-based) for sessions/tools; Canvas-based rendering
- Motion system: spawn, working, complete animations; respects reduced motion
- Haiku-style status summaries with low-cost calls; template fallback
- Agent hierarchy tree with expand/collapse

### Tasks by Track
- Frontend
  - Sidebar container with 60fps target; virtualization for 10+ agents
  - Sigil generator (seed = `sessionId|prompt|path|tool`); memoized and stable
  - Animation choreography using Familiar Spring; disable on reduced motion
  - Status summaries component with template fallback when network fails
  - Tree view with indentation and connective lines
- Backend
  - Ensure SSE includes sufficient metadata to infer agent lifecycle and hierarchy
  - Optional: light summarization endpoint for status lines (with strict token budget)

### Acceptance Criteria
- Sidebar stays at 60fps under simulated load (10+ agents)
- Users can tell what’s happening at a glance; hierarchy expands/collapses smoothly
- Summaries appear within 100ms perceived latency (or use template fallback)

### Validation & QA
- Perf sweeps on low-end hardware (frame timing via Instruments)
- Accessibility: VoiceOver descriptions for agent activity and state changes

### Risks & Mitigations
- Overdraw/perf regressions → Prefer Canvas; limit layer effects; profile continuously
- Token drift for summaries → Strict token caps and smart sampling cadence

### Estimate & Rollout
- Estimate: ~15–20 days (visual + perf work)
- Rollout: start hidden behind a user preference; enable for beta users first

---

## Cross-Phase Checklists

### Accessibility & Motion
- VoiceOver traversal verified
- Reduced Motion respected; animations use `.familiar` family
- Color contrast meets thresholds (script: `./scripts/color-contrast-checker.sh`)

### Language & Tone (The Language Test)
- Conversational copy (“Is that ok?”, “Done!”, “Hmm, something went wrong”)
- No robotic/corporate phrasing; avoid leaking low-level errors to users

### Context Engineering
- All new tools/endpoints return metadata-first
- Enforce limits from `backend/src/palette_sidecar/config.py` (MAX_* constants)
- For truncation, include explicit expansion affordances in messages

### Design & Craft
- Align to 8pt grid via FamiliarSpacing
- Use Familiar tokens: spacing, radius, typography, colors
- Animations use Familiar Spring; jitter avoided in streaming UI

### Observability
- Add lightweight logs/metrics for: login attempts/success, slash-command usage, memory saves, cost alerts
- Ensure logs don’t include secrets or local paths

### Rollout & PR Hygiene
- Small, focused PRs per subsection
- PR description follows the template and The Ive Test
- Manual validation steps and screenshots for UI changes

---

## Current Status Snapshot (informative)

- Phase 1: Backend endpoints + CLI coordination implemented; UI state machine/security indicators/copy URL/success animation/error UX pending
- Phase 2–4: Planned; partial groundwork exists (design tokens, motion system, zero-state, usage summary, tool summary card)


As we implement phases, refactor:

1. **SettingsView.swift (539 lines)**
   - Extract auth sections to separate views
   - Consolidate status update logic

2. **FamiliarViewModel.swift (254 lines)**
   - Break event handling into handler methods
   - Move UsageTotals parsing to model layer

3. **claude_service.py (922 lines)**
   - Extract ClaudeLoginCoordinator to `auth_coordinator.py`
   - Unify auth status fetching functions

**Goal**: Reduce by ~400 LOC without losing capability

---

### Testing Strategy

**Phase 1**: Manual QA + unit tests for state machine
**Phase 2**: User testing with 5 new users (onboarding flow)
**Phase 3**: Integration tests for SDK features
**Phase 4**: Performance profiling (Instruments), visual regression tests

---

### Documentation Updates

As each phase completes:

- [ ] Update README with new features
- [ ] Add implementation guide to `docs/implementation/`
- [ ] Record decisions in ADR format
- [ ] Create demo GIFs for visual features

---

## Timeline Summary

| Phase     | Duration     | Key Deliverable                  |
| --------- | ------------ | -------------------------------- |
| Phase 1   | 1 week       | Polished Claude login flow       |
| Phase 2   | 2 weeks      | Intuitive settings & onboarding  |
| Phase 3   | 3 weeks      | SDK features exposed in UI       |
| Phase 4   | 4 weeks      | Agent visualization sidebar      |
| **Total** | **10 weeks** | Production-ready, delightful app |

---

## Next Steps

1. **Review this plan** with team/stakeholders
2. **Start Phase 1** immediately (highest ROI)
3. **User test** after Phase 1 before continuing
4. **Adjust phases** based on feedback and priorities

---

**Last Updated**: September 29, 2025
**Status**: 📋 PLANNED - Ready to execute Phase 1
