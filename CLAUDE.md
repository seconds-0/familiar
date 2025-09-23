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