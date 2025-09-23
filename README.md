# AI Assistant for Raycast

An AI assistant that can actually control your computer. Hit `Cmd+Cmd` and type what you want done.

## Features

- **Natural Language Interface**: Just type what you want, no commands to learn
- **Real Computer Control**: Can read files, run commands, make edits (coming soon)
- **Streaming Responses**: See the AI's thoughts as it works
- **Persistent Sessions**: Your conversation continues where you left off

## Installation

1. Clone this repository
2. Install dependencies: `npm install`
3. Run in development mode: `npm run dev`
4. Or build and install: `npm run build && ray import dist`

## Setup

1. Get an API key from [console.anthropic.com](https://console.anthropic.com)
2. Add it in Raycast Preferences → AI Assistant → Anthropic API Key
3. Hit `Cmd+Cmd` (or set your own shortcut) to open the assistant

## Usage Examples

Try these prompts:
- "What files are in this directory?"
- "Read the package.json file"
- "Explain this error: [paste error message]"
- "What's in my downloads folder?"
- "Show me all TypeScript files here"

## Development

```bash
# Run in development mode (with hot reload)
npm run dev

# Build for production
npm run build

# Lint code
npm run lint

# Fix linting issues
npm run fix-lint
```

## Steel Thread Status

This is the minimal MVP (steel thread) implementation. Currently supports:
- ✅ Reading files and directories via MCP filesystem server
- ✅ Natural language understanding with Claude Code SDK
- ✅ Streaming responses with proper message type handling
- ✅ Per-directory session persistence
- ✅ Permission system with canUseTool callback
- ✅ Visual icons for better UX
- ✅ Proper error handling

Coming next:
- 🚧 File editing capabilities (Edit, Write tools)
- 🚧 Command execution (Bash tool)
- 🚧 Progressive trust levels
- 🚧 Claude.ai login support
- 🚧 Additional MCP servers (git, search)

## Architecture

Built with:
- Raycast API for the UI
- Claude Code SDK for AI capabilities
- TypeScript for type safety
- React for component management

## License

MIT