# Code Simplification Opportunities

**Status**: 📋 PLANNED
**Purpose**: Reduce complexity while maintaining capability
**Target Reduction**: ~400 LOC across Swift and Python

---

## Overview

The current codebase (19 Swift files, ~2,500 LOC + Python backend) works well but has accumulated complexity. This document identifies specific refactoring opportunities that will:

1. **Improve readability** - Clearer separation of concerns
2. **Reduce duplication** - DRY up repeated patterns
3. **Enhance testability** - Smaller, focused units
4. **Maintain capability** - Zero feature regression

---

## Swift Code (macOS App)

### 1. SettingsView.swift (539 lines → ~380 lines)

**Current Problems**:

- Single massive view with nested auth logic
- Four similar status update functions
- Deeply nested state management
- Hard to test individual sections

#### Refactoring Plan

**Extract Auth Sections** (saves ~100 lines):

```swift
// NEW FILE: ClaudeLoginSection.swift
struct ClaudeLoginSection: View {
    @Binding var hasSession: Bool
    @Binding var account: String?
    @Binding var isLoading: Bool
    let onSignIn: () -> Void
    let onSignOut: () -> Void
    let onRefresh: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Current implementation from lines 162-202
        }
    }
}

// NEW FILE: APIKeySection.swift
struct APIKeySection: View {
    @Binding var apiKey: String
    @Binding var isVisible: Bool
    let onPaste: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Current implementation from lines 117-160
        }
    }
}

// UPDATED: SettingsView.swift
var authenticationSection: some View {
    VStack(alignment: .leading, spacing: 12) {
        Text("Authentication")
            .font(.headline)

        Picker("Authentication", selection: $selectedAuthMode) {
            ForEach(AuthMode.allCases) { mode in
                Text(mode.label).tag(mode)
            }
        }
        .pickerStyle(.segmented)

        switch selectedAuthMode {
        case .claudeAi:
            ClaudeLoginSection(
                hasSession: $hasClaudeSession,
                account: $claudeAccount,
                isLoading: $isLoggingIn || $isLoggingOut,
                onSignIn: signInClaude,
                onSignOut: { isLogoutConfirmationPresented = true },
                onRefresh: { Task { await refreshClaudeStatus(manual: true) } }
            )
        case .apiKey:
            APIKeySection(
                apiKey: $apiKey,
                isVisible: $isApiKeyVisible,
                onPaste: pasteFromClipboard
            )
        }
    }
}
```

**Consolidate Status Updates** (saves ~40 lines):

```swift
// CURRENT: 4 separate functions
// - updateStatusForClaudeMode(with:)
// - updateStatusForClaudeMode()
// - updateStatusForApiMode()
// - updateAuthState(from:overrideStatus:)

// PROPOSED: Single unified function
private func updateStatusMessage(
    mode: AuthMode,
    authenticated: Bool,
    account: String?,
    overrideMessage: String? = nil
) {
    if let override = overrideMessage {
        statusMessage = override
        statusColor = .secondary
        return
    }

    switch (mode, authenticated) {
    case (.claudeAi, true):
        statusMessage = account.map { "Signed in as \($0)." } ?? "Claude account connected."
        statusColor = .green
    case (.claudeAi, false):
        statusMessage = "Sign in to Claude.ai to enable Claude Code."
        statusColor = .orange
    case (.apiKey, true):
        statusMessage = "API key configured."
        statusColor = .green
    case (.apiKey, false):
        statusMessage = "Enter your Anthropic API key to enable Claude Code."
        statusColor = .orange
    }
}
```

**Simplify Auth Logic** (saves ~20 lines):

```swift
// CURRENT: Manual state tracking with multiple @State vars
@State private var isLoggingIn = false
@State private var isLoggingOut = false
@State private var isRefreshingAuth = false
@State private var didOpenLoginURL = false

// PROPOSED: Single auth state enum
enum AuthOperationState {
    case idle
    case signingIn(didOpenURL: Bool)
    case signingOut
    case refreshing
}

@State private var authOperation: AuthOperationState = .idle

var isAuthBusy: Bool {
    if case .idle = authOperation { return false }
    return true
}
```

#### Impact

- **Before**: 539 lines, hard to navigate, duplicated logic
- **After**: ~380 lines, clear sections, testable components
- **Savings**: 159 lines (29% reduction)

---

### 2. FamiliarViewModel.swift (254 lines → ~200 lines)

**Current Problems**:

- Large `handle(_ event:)` switch statement (30 lines)
- UsageTotals parsing mixed with view logic
- Loading message logic could be extracted

#### Refactoring Plan

**Extract Event Handlers** (saves ~20 lines):

```swift
// CURRENT: Single switch with inline handling
private func handle(_ event: SidecarEvent) {
    switch event.type {
    case .assistantText:
        if let text = event.text {
            transcript.append(text)
        }
    case .toolResult:
        toolSummary = ToolSummary.from(event: event)
    // ... 6 more cases
    }
}

// PROPOSED: Dedicated handler methods
private func handle(_ event: SidecarEvent) {
    switch event.type {
    case .assistantText: handleAssistantText(event)
    case .toolResult: handleToolResult(event)
    case .permissionRequest: handlePermissionRequest(event)
    case .permissionResolution: handlePermissionResolution(event)
    case .result: handleResult(event)
    case .error: handleError(event)
    default: break
    }
}

private func handleAssistantText(_ event: SidecarEvent) {
    guard let text = event.text else { return }
    transcript.append(text)
}

private func handleToolResult(_ event: SidecarEvent) {
    toolSummary = ToolSummary.from(event: event)
}

// ... etc for each event type
```

**Move UsageTotals Parsing to Model** (saves ~20 lines):

```swift
// MOVE FROM: FamiliarViewModel.swift
// TO: UsageTotals struct in Models/

extension UsageTotals {
    init?(usageDict: [String: Any]?, costDict: [String: Any]?) {
        // Current implementation from lines 34-47
    }

    private static func parseInt(_ value: Any?) -> Int? {
        // Current implementation from lines 49-60
    }

    private static func parseDouble(_ value: Any?) -> Double? {
        // Current implementation from lines 62-73
    }
}

// SIMPLIFIED: FamiliarViewModel.swift
private func handleResult(_ event: SidecarEvent) {
    if let totals = UsageTotals(usageDict: event.usage, costDict: event.cost) {
        usageTotals = usageTotals.adding(totals)
        lastUsage = totals
    }
    isStreaming = false
}
```

**Extract Loading Message Controller** (saves ~14 lines):

```swift
// NEW FILE: LoadingMessageController.swift
final class LoadingMessageController {
    private let phrases: [String]
    private var currentMessage: String?

    init(phrases: [String]) {
        self.phrases = phrases
    }

    func nextMessage() -> String {
        var candidate = phrases.randomElement() ?? "Working on it…"
        if let current = currentMessage, phrases.count > 1 {
            var attempts = 0
            while candidate == current && attempts < 5 {
                candidate = phrases.randomElement() ?? candidate
                attempts += 1
            }
        }
        currentMessage = candidate
        return candidate
    }
}

// SIMPLIFIED: FamiliarViewModel.swift
private let loadingController = LoadingMessageController(phrases: [
    "Tracing the magical ley lines…",
    "Consulting the grimoire of code…",
    // ...
])

private func startLoadingMessages() {
    loadingTask?.cancel()
    loadingMessage = loadingController.nextMessage()
    loadingTask = Task { [weak self] in
        while !(Task.isCancelled) {
            try? await Task.sleep(nanoseconds: 2 * 1_000_000_000)
            await MainActor.run {
                self?.loadingMessage = self?.loadingController.nextMessage()
            }
        }
    }
}
```

#### Impact

- **Before**: 254 lines, monolithic event handling
- **After**: ~200 lines, focused responsibilities
- **Savings**: 54 lines (21% reduction)

---

### 3. Minor Simplifications Across Other Files

**AppState.swift** (139 lines → ~120 lines):

- Combine `healthIsOK` and `configurationIsOK` into single `SystemStatus` enum
- Extract `updateStatus()` logic into computed property
- **Savings**: 19 lines

**ToolSummaryView.swift** (~80 lines):

- Already well-factored, no major changes
- Consider extracting snippet rendering to separate view

**ApprovalSheet.swift** (~100 lines):

- Extract diff rendering to `DiffPreviewView` component
- Add syntax highlighting as separate extension
- **Savings**: Neutral (improves modularity, not LOC)

---

## Python Code (Backend Sidecar)

### 1. claude_service.py (922 lines → ~700 lines)

**Current Problems**:

- `ClaudeLoginCoordinator` (185 lines) embedded in service file
- Duplicate URL pattern matching (2 regex patterns)
- Three similar async auth functions

#### Refactoring Plan

**Extract Login Coordinator** (saves ~185 lines from main file):

```python
# NEW FILE: backend/src/palette_sidecar/auth_coordinator.py
"""Claude.ai login flow coordination."""

import asyncio
import re
from dataclasses import dataclass

@dataclass
class ClaudeAuthStatus:
    active: bool
    account: str | None = None
    message: str | None = None
    login_url: str | None = None
    pending: bool = False

class ClaudeLoginCoordinator:
    """Manage Claude.ai login flows triggered via the CLI."""
    # Current implementation from lines 180-365
    pass

# Export public functions
async def trigger_claude_login() -> ClaudeAuthStatus:
    """Public entry point for initiating Claude.ai login."""
    return await login_coordinator.begin_login()

async def trigger_claude_logout() -> ClaudeAuthStatus:
    """Public entry point for logging out of Claude.ai."""
    await login_coordinator.cancel()
    status = await perform_claude_logout()
    return login_coordinator.merge_status(status)

login_coordinator = ClaudeLoginCoordinator()

# UPDATED: claude_service.py imports from auth_coordinator
from .auth_coordinator import (
    ClaudeAuthStatus,
    trigger_claude_login,
    trigger_claude_logout,
    refresh_claude_auth_state,
)
```

**Unify URL Pattern Matching** (saves ~10 lines):

```python
# CURRENT: Two separate patterns
ANSI_ESCAPE_RE = re.compile(r"\x1B\[[0-?]*[ -/]*[@-~]")
URL_PATTERN = re.compile(r"https?://[^\s]+")

# Plus another in _parse_account_email
match = re.search(r"[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}", output)

# PROPOSED: Consolidated patterns module
# NEW FILE: backend/src/palette_sidecar/patterns.py
"""Regex patterns for parsing CLI output."""
import re

ANSI_ESCAPE = re.compile(r"\x1B\[[0-?]*[ -/]*[@-~]")
URL = re.compile(r"https?://[^\s)]+")  # Note: exclude trailing )
EMAIL = re.compile(r"[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}")
CLAUDE_LOGIN_URL = re.compile(r"(https?://(?:api\.)?claude\.ai/[^\s)]+)")

def extract_url(text: str) -> str | None:
    """Extract first URL from text, preferring claude.ai domains."""
    # Try Claude-specific first
    if match := CLAUDE_LOGIN_URL.search(text):
        return match.group(1)
    # Fall back to any URL
    if match := URL.search(text):
        return match.group(0).rstrip(")")
    return None

def extract_email(text: str) -> str | None:
    """Extract email address from text."""
    if match := EMAIL.search(text):
        return match.group(0)
    return None

def strip_ansi(text: str) -> str:
    """Remove ANSI escape codes from text."""
    return ANSI_ESCAPE.sub("", text)
```

**Consolidate Auth Status Functions** (saves ~15 lines):

```python
# CURRENT: Three similar functions
async def fetch_claude_session_status() -> ClaudeAuthStatus:
    # 40 lines of CLI invocation and parsing

async def perform_claude_logout() -> ClaudeAuthStatus:
    # 18 lines of CLI invocation and parsing

async def refresh_claude_auth_state() -> ClaudeAuthStatus:
    # Calls fetch_claude_session_status and merges

# PROPOSED: Single base function with command parameter
async def _execute_claude_cli_command(
    command: list[str],
    *,
    expect_json: bool = False,
) -> ClaudeAuthStatus:
    """Execute Claude CLI command and parse auth status from output."""
    for attempt, cmd_args in enumerate([command, ["whoami"], ["session", "status"]]):
        try:
            code, stdout, stderr = await _run_claude_cli(*cmd_args)
        except Exception as exc:
            if attempt == 2:  # Last attempt
                return ClaudeAuthStatus(active=False, message=str(exc))
            continue

        output = stdout.strip() or stderr.strip()

        if code != 0:
            if "unknown option" in output.lower():
                continue  # Try next command variant
            return ClaudeAuthStatus(active=False, message=output)

        # Try JSON parsing if requested
        if expect_json:
            with suppress(json.JSONDecodeError):
                payload = json.loads(stdout)
                email = payload.get("account") or payload.get("email")
                if email:
                    return ClaudeAuthStatus(active=True, account=email)

        # Fall back to text parsing
        email = patterns.extract_email(output)
        if email:
            return ClaudeAuthStatus(active=True, account=email, message=output)

        if output:
            return ClaudeAuthStatus(active=True, message=output)

    return ClaudeAuthStatus(active=False)

async def fetch_claude_session_status() -> ClaudeAuthStatus:
    """Attempt to resolve the current Claude.ai session status via CLI."""
    return await _execute_claude_cli_command(["whoami", "--json"], expect_json=True)

async def perform_claude_logout() -> ClaudeAuthStatus:
    """Terminate Claude.ai authentication."""
    status = await _execute_claude_cli_command(["logout"])
    if status.active:  # Force clear on successful logout
        status.active = False
    return status
```

#### Impact

- **Before**: 922 lines, mixed concerns
- **After**: ~700 lines in main file, ~220 in extracted modules
- **Savings**: 222 lines of perceived complexity in main file

---

### 2. api.py (268 lines → ~240 lines)

**Current Issues**:

- Repeated `_auth_response()` dict construction
- Redundant try/except patterns

#### Quick Wins

**Use Pydantic Models for Responses** (saves ~15 lines):

```python
# NEW: models.py addition
class ClaudeAuthResponse(BaseModel):
    active: bool
    account: str | None = None
    pending: bool = False
    message: str | None = None
    loginUrl: str | None = Field(None, alias="login_url")

    class Config:
        populate_by_name = True

# SIMPLIFIED: api.py
@app.post("/auth/claude/login")
async def auth_claude_login() -> ClaudeAuthResponse:
    if _current_settings.auth_mode != AUTH_MODE_CLAUDE:
        raise HTTPException(400, detail="Switch to Claude.ai login mode first")

    status_obj = await trigger_claude_login()
    _current_settings.claude_session_active = status_obj.active
    _current_settings.claude_account = status_obj.account
    save_settings(_current_settings)

    return ClaudeAuthResponse(
        active=status_obj.active,
        account=status_obj.account,
        pending=status_obj.pending,
        message=status_obj.message,
        login_url=status_obj.login_url,
    )
```

**Error Handling Decorator** (saves ~13 lines):

```python
# NEW: Reusable error handler
def handle_settings_errors(func):
    """Decorator for settings endpoints with consistent error handling."""
    @wraps(func)
    async def wrapper(*args, **kwargs):
        try:
            return await func(*args, **kwargs)
        except Exception as exc:
            raise HTTPException(400, detail=str(exc)) from exc
    return wrapper

# APPLY to /settings endpoints
@app.post("/settings")
@handle_settings_errors
async def update_settings(payload: SettingsPayload) -> JSONResponse:
    # Remove try/except boilerplate, focus on business logic
```

#### Impact

- **Before**: 268 lines, repeated patterns
- **After**: ~240 lines, cleaner endpoints
- **Savings**: 28 lines (10% reduction)

---

## Summary of Simplifications

| File                    | Before    | After     | Savings | % Reduction |
| ----------------------- | --------- | --------- | ------- | ----------- |
| **Swift**               |
| SettingsView.swift      | 539       | 380       | 159     | 29%         |
| FamiliarViewModel.swift | 254       | 200       | 54      | 21%         |
| AppState.swift          | 139       | 120       | 19      | 14%         |
| **Python**              |
| claude_service.py       | 922       | 700       | 222     | 24%         |
| api.py                  | 268       | 240       | 28      | 10%         |
| **Total**               | **2,122** | **1,640** | **482** | **23%**     |

---

## Implementation Strategy

### Phase 1: Low-Risk Extractions (Week 1)

1. Extract `ClaudeLoginSection` and `APIKeySection` from SettingsView
2. Move `UsageTotals` parsing to model layer
3. Create `patterns.py` module for regex consolidation

### Phase 2: Behavioral Refactoring (Week 2)

4. Extract `ClaudeLoginCoordinator` to separate file
5. Consolidate status update functions in SettingsView
6. Extract event handlers in FamiliarViewModel

### Phase 3: Polish & Validation (Week 3)

7. Add unit tests for extracted components
8. Verify zero behavioral changes (compare test coverage)
9. Update documentation and code comments

---

## Testing Approach

**Unit Tests**:

- Each extracted component gets dedicated test file
- Cover edge cases that were hard to test before
- Aim for 80%+ coverage on new modules

**Integration Tests**:

- No existing tests should break
- Behavior should be identical before/after
- Use snapshot tests for UI components

**Manual QA**:

- Full smoke test after each refactoring
- Verify auth flows still work
- Check error handling paths

---

## Success Criteria

- [ ] 400+ LOC reduction without losing features
- [ ] All existing tests pass
- [ ] New components have unit tests
- [ ] Code review approval from 1+ reviewer
- [ ] Zero user-facing changes (invisible refactor)

---

**Last Updated**: September 29, 2025
**Status**: 📋 PLANNED - Start after Phase 1 enhancements
