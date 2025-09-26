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
- When investigating SDK behavior, reference `docs/claude-code-sdk.md` before diving into external sources.
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
- The Swift client sits under `apps/mac/FamiliarApp/`; resolve dependencies with `swift build` or open `Package.swift` in Xcode for UI iteration.
- Validate `assets/claude-cli/cli.js` with `node assets/claude-cli/cli.js --help` after modifying bundled tooling.
- Propose testing strategies aligned with the chosen stack (e.g., pytest, XCTest) and capture rationale in `docs/prd.md` or a dedicated testing note.

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
