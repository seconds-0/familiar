# Claude Control for Raycast

Quick‑open AI assistant in Raycast that actually acts. The Raycast command provides the UI; a small local Helper performs file edits, search, and shell actions.

## Features

- **Natural Language Interface**: Just type what you want, no commands to learn
- **Real Actions**: Read/edit files, search, and run commands (via Helper)
- **Streaming Responses**: See the AI's thoughts as it works
- **Persistent Sessions**: Your conversation continues where you left off
- **Limited Mode**: Basic read/edit/grep in‑process if Helper is not installed

## Installation

1. Clone this repository
2. Install dependencies: `npm install`
3. Run in development mode: `npm run dev`
4. First run opens an install wizard to set up the Helper

## Setup & Auth

Choose one:

- Sign in with Claude (recommended): the Helper handles SDK login; tokens stay local to the Helper
- Use API key: set in Raycast Preferences → Anthropic API Key

Hit `Cmd+Cmd` to open the assistant.

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

## Helper & Limited Mode

- With Helper: full capabilities (read/edit/diff, grep/glob, bash with streaming)
- Without Helper: limited mode (in‑process read/edit/grep only)

## Architecture

Built with:
- Raycast API for the UI and permissions
- Local Helper (localhost/Unix socket) for Claude Code SDK, files, and shell
- TypeScript for type safety
- React for component management

## License

MIT