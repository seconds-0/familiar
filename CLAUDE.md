# CLAUDE.md

Guidance for Claude Code (claude.ai/code) when working inside this repository.

## Project Overview

This repository designs a **native macOS application** that embeds the Claude Code TypeScript SDK to provide a system-wide command palette, MCP orchestration, and deep filesystem integrations. The end goal is a first-party desktop experience that can spawn processes, manage trust boundaries, and present rich AI-assisted workflows without compromise.

## Current Status

🚧 **Architecture Planning Phase**

Active work involves comparing desktop frameworks, defining IPC boundaries, and documenting product flows. No production-ready source code ships yet; most artifacts live in documentation and tool bundles.

## Core Design Philosophy

### The Ive Test (Primary Decision Framework)
Every decision must pass these four criteria:
- **Is it inevitable?** (feels obvious in hindsight)
- **Is it essential?** (nothing superfluous)
- **Does it show care?** (attention to detail perceptible)
- **Is the design invisible?** (user thinks about task, not UI)

Reference: docs/design/aesthetic-system.md:851-857

### Sophisticated Simplicity
Familiar is designed for **everyone** - from grandma organizing files to developers debugging systems.

Core principles:
- **Immediately understandable**: No learning curve
- **Joyful to use**: Delightful interactions, not transactional
- **Respectful of attention**: Present when invoked, absent otherwise
- **Rewarding to explore**: Hidden depth for curious users

"Can grandma understand this?" is the litmus test.

Reference: docs/design/aesthetic-system.md:5-18

### The Four Pillars
1. **Clarity Over Decoration**: Every element serves communication
2. **Joy Through Interaction**: Delight from how it works, not looks
3. **Human Language**: "Is that ok?" not "Approve?"
4. **Mystery Through Discovery**: Hidden features reward exploration

Reference: docs/design/aesthetic-system.md:22-53

## Decision Frameworks

### The Three-Layer Abstraction System
**Layer 1: Human Outcomes (Default)** - "Organized 47 images"
**Layer 2: How It Works (Collapsed)** - "I used a Python script..."
**Layer 3: Technical Details (Hidden)** - Full code, paths, errors

**Key Principle**: Users choose their depth. Most stay at Layer 1. That's correct.

Reference: docs/design/aesthetic-system.md:363-392

### The Grandma Test
Before implementing or describing anything:
- Can grandma understand this?
- Would I say this to a friend?
- Or does it sound corporate/robotic?

### The Language Test
**Good**: "Is that ok?", "Done!", "Hmm, something went wrong"
**Bad**: "Approve?", "Operation completed", "Error: Permission denied"

Reference: docs/design/aesthetic-system.md:283-313

### Motion First, Sound Silent
**Distinctive Element**: The "Familiar Spring" animation
```swift
Animation.spring(response: 0.3, dampingFraction: 0.7)
```

**Sound Philosophy**: Default silent. Voice output when enabled, UI sounds OFF.

Reference: docs/design/aesthetic-system.md:165-237, 466-519

## Non-Negotiable Constraints

### Accessibility Requirements
- WCAG AA minimum (AAA preferred)
- VoiceOver fully supported
- Keyboard navigation complete
- High contrast mode respected
- Reduced motion honored
- Minimum 44pt touch targets
- Color never sole information carrier

**Accessibility is not optional. It's how we ensure universality.**

Reference: docs/design/aesthetic-system.md:421-442

### Human Language Standards
**Do**:
- "I can organize your desktop for you"
- "Is that ok?"
- "Done! Your files are organized"
- "Hmm, I can't access that file"

**Don't**:
- "Familiar wants to execute command"
- "Approve?"
- "Operation completed successfully"
- "Error: Permission denied [Errno 13]"

Reference: docs/design/aesthetic-system.md:283-313

### Permission Philosophy
Permissions exist to **build trust, not satisfy legal requirements**.

**Template**:
```
I can [action] for you:
• [Specific detail with real numbers]
• [Another specific detail]

Is that ok?

[Show me how ▼]  [Not right now]  [Yes, do it]
```

Reference: docs/design/aesthetic-system.md:318-360

## Mandatory Design Consultation

### Before ANY Design Decision
1. Read `docs/design/aesthetic-system.md`
2. Apply **The Ive Test** (is it inevitable, essential, careful, invisible?)
3. Verify it passes **The Grandma Test**

### Before Implementing Visual Changes
1. Check **locked design tokens** in `docs/design/aesthetic-system.md:522-663`
2. Use 8pt grid spacing (xs: 8, sm: 16, md: 24, lg: 32, xl: 48)
3. Use corner radius (control: 8pt, card: 12pt)
4. Use The Familiar Spring for all animations
5. Consult `docs/design/visual-improvements.md` for patterns

### Before Adding Features
1. Read `docs/design/hidden-delights.md:493-516`
2. Apply **The Test**:
   - Does it delight without confusing?
   - Does it interfere with core functionality?
   - Is it accessible?
   - Is it tasteful? (Would Jony Ive approve?)

### Before Implementing Permissions
1. Use permission language templates from `docs/design/aesthetic-system.md:318-360`
2. Say specifically what will happen
3. Use real numbers (47 images, not "files")
4. Make approval collaborative, not bureaucratic

### Before Implementing Steel Thread Features
1. Read `docs/implementation/steel-thread-v1.md`
2. **Steel Thread Definition**: The smallest, fully polished workflow that proves the product vision
3. V1 is done when a new user can complete the full workflow cleanly

### For SDK Integration
1. **Always** consult `docs/reference/claude-agent-sdk.md`
2. Understand Options, permissions, hooks, MCP servers
3. Follow established patterns

## Core Vocabulary

### Product Language
- **Familiar** (not "Familiar App" or "the tool")
- **Summon** (not "open" or "launch")
- **Steel Thread** (not "MVP" or "v0.1")
- **Layer 1/2/3** (technical abstraction levels)
- **The Ive Test** (primary design framework)
- **Sophisticated Simplicity** (core aesthetic)

### Permission Language
- "Is that ok?" (not "Approve?")
- "Yes, do it" / "Sounds good" (not "Approve")
- "Not right now" / "No thanks" (not "Deny")
- "Show me how" (not "Show details")

### Technical Terms
- **Sidecar** (Python FastAPI backend)
- **PreToolUse** / **PostToolUse** (permission hooks)
- **The Familiar Spring** (signature animation)
- **Breathing Dot** (subtle progress, not spinner)

## Collaboration Principles

1. **Documentation First**: Treat `docs/` as the source of truth. Start with **[docs/00-README.md](docs/00-README.md)** for navigation.
   - Reference docs: `docs/reference/` (claude-code-sdk.md, swiftui-reference.md)
   - Implementation guides: `docs/implementation/` (phased-enhancements.md, steel-thread-v1.md)
   - Design specifications: `docs/design/` (aesthetic-system.md, visual-improvements.md)
   - Future explorations: `docs/future/`
2. Develop the Python sidecar inside `backend/` using `uv` tooling; keep FastAPI endpoints documented and synced with the Swift client.
3. Keep `assets/claude-cli/` intact; it provides the canonical CLI runtime for local validation and should be smoke-tested after dependency changes.
4. Run Swift unit tests from anywhere via `swift test --package-path apps/mac/FamiliarApp` or the convenience script `./test-swift.sh` (supports `--filter`, `--verbose`, `--enable-code-coverage`, etc.).
5. Update `AGENTS.md` whenever contributor workflows or security expectations shift so human teammates stay aligned with automated guidance here.
6. Prefer additive planning artifacts (diagrams, ADRs) over speculative code until an architecture option is approved.

## Framework Research & Documentation

**MANDATORY: Always Use EXA-CODE MCP Server**

For all framework-related questions, implementation patterns, and API research, ALWAYS use the `get_code_context_exa` tool before implementing or making architectural decisions. This is especially critical for:

### Primary Framework Targets
- **SwiftUI** - UI components, navigation, state management, macOS-specific APIs
- **FastAPI** - Async endpoints, dependency injection, middleware, SSE streaming
- **Claude Code SDK** - Session management, MCP server integration, tool execution patterns

### EXA-CODE Usage Patterns

**Before implementing any feature:**
```
Use get_code_context_exa to search for:
- "SwiftUI [specific component] best practices examples"
- "FastAPI [specific pattern] implementation guide"
- "Claude Code SDK [functionality] usage examples"
```

**For debugging and troubleshooting:**
```
Use get_code_context_exa to find:
- "SwiftUI [error/issue] solutions GitHub"
- "FastAPI [problem] troubleshooting examples"
- "Claude Code SDK [specific issue] workarounds"
```

**For architecture decisions:**
```
Use get_code_context_exa to research:
- "[Framework] [pattern] vs [alternative] comparison"
- "[Technology] production examples real-world"
- "[Integration] implementation patterns 2024 2025"
```

### Integration with Local Search

1. **First**: Use `get_code_context_exa` for external framework knowledge
2. **Then**: Use targeted `rg` queries for local codebase exploration
3. **Finally**: Reference `docs/` for project-specific architectural decisions

This approach ensures you have the most current framework knowledge before diving into implementation.

## Search & Analysis Tips

- Use targeted `rg` queries or TypeScript-aware tooling to explore the codebase. Avoid wide wildcard searches that inflate context; narrow by directory or file type.
- When investigating SDK behavior, reference `docs/reference/claude-code-sdk.md` before diving into external sources.
- For implementation patterns, check `docs/implementation/` guides for established approaches.
- Summarize findings with file paths and line numbers so future contributors can trace decisions quickly.

## MCP Server Configuration

The project uses MCP (Model Context Protocol) servers for enhanced AI capabilities. Configuration is managed in `.mcp.json`:

### Active MCP Servers

**EXA-CODE Server** (Production Ready)
- **Purpose**: Framework research, code examples, documentation search
- **Transport**: SSE (Server-Sent Events)
- **Endpoint**: `https://mcp.exa.ai/mcp`
- **Tools Available**:
  - `get_code_context_exa` - Search code examples and documentation
  - `web_search_exa` - Enhanced web search for development
  - `company_research` - Research companies and organizations
  - `linkedin_search` - LinkedIn profile and company search

### Configuration Management

- **File**: `.mcp.json` (project root)
- **Loading**: Automatic via `claude_service.py:117-127`
- **Schema**: Must include `type` field (`"sse"`, `"stdio"`, `"http"`)
- **Authentication**: API keys stored in `headers.Authorization`

### Adding New MCP Servers

1. Update `.mcp.json` with new server configuration
2. Restart backend service to load changes
3. Test with: `uv run python -c "from src.palette_sidecar.claude_service import session; print(session._options.mcp_servers)"`

## Build & Test Expectations

- Backend lives under `backend/`; run `uv run uvicorn palette_sidecar.api:app --host 127.0.0.1 --port 8765 --reload` for local development.
- Execute backend tests with `uv run pytest tests/ -v` after modifying the FastAPI sidecar or Claude session logic.
- The Swift client sits under `apps/mac/FamiliarApp/`; resolve dependencies with `swift build` or open `Package.swift` in Xcode for UI iteration.
- Validate `assets/claude-cli/cli.js` with `node assets/claude-cli/cli.js --help` after modifying bundled tooling.
- Propose testing strategies aligned with the chosen stack (e.g., pytest, XCTest) and capture rationale in implementation docs.

### Testing Commands (from project root)

**Swift Tests:**
```bash
# Option 1: Direct command
swift test --package-path apps/mac/FamiliarApp

# Option 2: Convenience script
./test-swift.sh

# Option 3: With filters
./test-swift.sh --filter PromptTextEditorTests
```

**Backend Tests:**
```bash
cd backend && uv run pytest tests/ -v
```

**All Tests:**
```bash
# Run both Swift and Python tests
./test-swift.sh && cd backend && uv run pytest tests/ -v
```

## Architecture Requirements

- Full Claude Code SDK integration, including MCP servers and shell tool execution
- Global hotkey activation with responsive UI overlays
- Fine-grained permission and audit flows for file edits, shell commands, and external services
- Real-time process monitoring with ability to cancel or retry tasks

## Security & Privacy Considerations

- Never commit secrets, API keys, or personal data. Reference secure storage solutions (macOS Keychain, environment variables) when documenting setup steps.
- Document any network access, update mechanisms, or background services in `docs/` so reviewers can evaluate threat surfaces early.

Following these guidelines keeps the project focused on shipping a robust native macOS companion for Claude Code.
