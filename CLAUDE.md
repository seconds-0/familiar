# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Raycast extension that integrates the Claude Code TypeScript SDK to create an AI assistant capable of controlling your computer through natural language commands. The project is currently in "steel thread" MVP status - a minimal working implementation that establishes the core architecture.

## Development Commands

```bash
# Start development mode with hot reload
npm run dev

# Build production bundle
npm run build

# Run linter
npm run lint

# Auto-fix linting issues
npm run fix-lint

# Publish to Raycast Store
npm run publish
```

## Search Strategy - Always Use Agent

**CRITICAL**: ALWAYS dispatch the `code-search-specialist` agent for ALL searches. Never use direct grep, rg, sg, or find commands. The agent has superior capabilities and reduces context usage.

### Why Agent-First Search

The `code-search-specialist` agent combines multiple powerful tools:
- **Code Search**: Glob, Grep, Read for comprehensive repository exploration
- **Web Search**: WebSearch, WebFetch for documentation and online resources
- **Context Tools**: MCP tools for library documentation and IDE diagnostics
- **Progress Tracking**: TodoWrite for complex multi-step searches
- **Intelligence**: Can refine searches based on initial results and cross-reference findings

### Search Prompt Templates

#### 1. Finding Implementation Patterns
```
"Search the codebase for [PATTERN/FEATURE] implementation:
1. Find all function/class definitions related to [PATTERN]
2. Locate usage examples and imports
3. Identify related test files
4. Check configuration files that affect [PATTERN]
5. If relevant, search online docs for [PATTERN] best practices
Return: File paths with line numbers, key code snippets, and architectural insights"
```

#### 2. Understanding Dependencies and Libraries
```
"Investigate how [LIBRARY/MODULE] is used in this project:
1. Check package.json for version and related dependencies
2. Find all imports and actual usage patterns
3. Search online for current documentation and migration guides
4. Identify any deprecated patterns or potential upgrades
5. Look for similar projects' usage examples online
Return: Current usage patterns, version compatibility, and modernization opportunities"
```

#### 3. Debugging and Error Tracing
```
"Trace the execution flow for [FEATURE/BUG/ERROR]:
1. Find the error message or symptom in the code
2. Trace back through the call stack
3. Identify all error handlers and edge cases
4. Search web for similar issues and solutions
5. Check related configuration and environment setup
Return: Complete call chain, failure points, and recommended fixes"
```

#### 4. Cross-Reference and Refactoring Search
```
"Find all connections between [COMPONENT_A] and [COMPONENT_B]:
1. Direct imports and dependencies
2. Shared types, interfaces, or utilities
3. Event listeners, callbacks, or message passing
4. Data flow and state management connections
5. Any indirect coupling through third components
Return: Dependency graph, coupling analysis, and refactoring suggestions"
```

#### 5. API and Integration Search
```
"Analyze [API/SERVICE] integration:
1. Find all API endpoints or service calls
2. Locate authentication and configuration
3. Check error handling and retry logic
4. Search online for API documentation updates
5. Find integration tests and mocks
Return: Integration points, current implementation, and improvement opportunities"
```

### Effective Agent Prompting Tips

1. **Be Specific**: Include exact names, patterns, or error messages
2. **Set Clear Objectives**: Tell the agent what insights you need
3. **Request Structure**: Ask for organized output (file paths, line numbers, summaries)
4. **Combine Sources**: Explicitly ask for both code and web searches when relevant
5. **Iterative Refinement**: Mention if you want the agent to dig deeper on findings

### Example Usage

### Testing & Debugging Utilities

- `npm run smoke:sdk`: launch the Claude SDK directly using the packaged CLI (`assets/claude-cli/cli.js`) to verify actor usability outside Raycast. The script prints event flow (`system`, `assistant`, etc.) and is an early guard against CLI packaging regressions.
- `npm run test`: executes unit, integration, and e2e harnesses. Integration tests copy a fake CLI and confirm `resolveClaudeCliPath()` finds it; e2e ensures the real SDK spawns successfully.
- Raycast preference `useMockClaude`: toggling this returns deterministic mock responses without invoking the SDK. Ideal for UI-only testing when networking or CLI setup is suspect.

Socket preparation: on extension boot, we anchor the CLAUDE CLI socket directory under `os.tmpdir()/claude-sockets` to avoid ephemeral path issues on macOS.

## Architecture

### Core Integration Flow
1. **User Input** → Raycast UI (`src/assistant.tsx`) captures natural language input via search bar
2. **Claude Query** → Uses `@anthropic-ai/claude-code` SDK's `query()` function with streaming enabled
3. **Session Management** → Persists conversation state in Raycast's LocalStorage per working directory
4. **Response Streaming** → Real-time updates to the List component as Claude responds

### Key Technical Decisions

- **Authentication**: Currently uses API key stored in Raycast preferences. Claude.ai login support is planned but not implemented.
- **Streaming**: Uses `includePartialMessages: true` to show responses as they arrive
- **Session Persistence**: Stores `sessionId` and `messages` in LocalStorage with debounced saves to reduce disk I/O
- **MCP Servers**: Configured for filesystem access with proper `stdio` type (requires @modelcontextprotocol/server-filesystem)

### Current Implementation Status

**Working:**
- Basic chat interface with streaming responses
- Session persistence across restarts (with debouncing)
- API key authentication
- Message history display
- Proper TypeScript types from SDK
- Immutable state updates during streaming
- AbortController for query cancellation
- MCP filesystem server configuration (stdio type)
- Error handling with proper type checking

**Partially Implemented:**
- MCP server integration (configured but requires @modelcontextprotocol/server-filesystem installation)
- File operations (Read, Grep, Glob allowed via canUseTool)

**Not Yet Implemented:**
- File writing operations (Write, Edit)
- Command execution (Bash)
- Full permission system and trust levels
- Progressive trust building
- Claude.ai authentication

## Code Structure

The codebase follows Raycast extension conventions with modular utilities:

- `src/assistant.tsx` - Main command implementation with UI and core logic
- `src/utils/types.ts` - TypeScript type definitions and SDK type re-exports
- `src/utils/session.ts` - Session management with debounced persistence
- `src/utils/mcp.ts` - MCP server configuration and path resolution
- `package.json` - Raycast extension manifest and scripts
- `raycast-env.d.ts` - Auto-generated TypeScript definitions from package.json

## Important Context

### Claude Code SDK Integration
The implementation now properly uses SDK types and handles all documented event types:
- `system` events with `init` subtype for session initialization
- `partial-assistant` events for streaming content updates
- `assistant` events for complete messages with tool uses
- `result` events for success, error, and interrupted states
- Supports both `sessionId` and `session_id` field variations

### Raycast Constraints
- Must use CommonJS module system (not ESM)
- React components must follow Raycast's component library
- Preferences are strongly typed via `raycast-env.d.ts`
- Build output goes to `dist/` directory

### Documentation Resources
The `docs/` directory contains comprehensive references:
- `prd.md` - Product requirements and vision
- `01-steelthread.md` - MVP implementation plan
- `claude-code-sdk.md` - SDK reference (note: some features not yet used)
- `raycast-api.md` - Raycast development guide
- `integration-guide.md` - Detailed implementation patterns
- `quick-reference.md` - Quick lookup for common patterns

## Current Limitations

1. MCP filesystem server requires manual installation of `@modelcontextprotocol/server-filesystem`
2. Write operations are still disabled in the permission handler
3. Trust level UI is present but not yet functional
4. The package.json author and icon need to be updated for Raycast Store submission

## Development Tips

- Use `ray develop` instead of `npm run dev` if you need more detailed error messages
- Check Raycast's development console (Cmd+Option+I when extension is open) for debugging
- The extension automatically appears in Raycast after running dev mode once
- Changes hot-reload but preferences changes require restart