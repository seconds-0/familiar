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
