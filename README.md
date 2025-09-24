# Claude for macOS (Native App)

> 🚧 **Project Status**: Architecture Planning Phase
> Designing a native macOS application that delivers Claude Code end-to-end

## Vision

Build a focused macOS companion that unlocks Claude Code's full capabilities through a global command palette and native integrations. The app should feel instantaneous, respect local guardrails, and make advanced automation approachable for every workspace.

## Why Native?

Embedding Claude Code directly into a macOS app removes sandbox and subprocess limitations. Native control means:
- ✅ Full Claude Code SDK access with streamlined tool permission flows
- ✅ Direct subprocess spawning for MCP servers and shell actions
- ✅ First-class filesystem integration for editing and diffing
- ✅ Tight coupling with macOS input, windows, and menu bar surfaces
- ✅ Real-time process oversight without IPC overhead

## Planned Features

### Core Functionality
- **Global Hotkey**: Cmd+Cmd for instant access
- **Complete Claude Code SDK**: Every tool, including Bash and MCP servers
- **Process Management**: Live logs, cancellation, and retries
- **Rich UI**: Markdown rendering, syntax highlighting, diff viewers

### User Experience
- Menu bar entry point with status insights
- Floating command palette that respects the active workspace
- Progressive trust and permission audit trails
- Conversation history scoped per project directory

## Technology Options Under Consideration

### Option 1: Electron
- Full Node.js runtime for SDK integration
- Mature ecosystem and cross-platform potential

### Option 2: Tauri
- Slim bundle footprint backed by Rust
- Security-forward architecture with WebView UI

### Option 3: Swift + Node Bridge
- Deep macOS integration and native feel
- Requires bridging for Node-based tooling

## Project Structure

```
familiar/
├── README.md                  # Project overview
├── docs/                      # Architecture research and SDK references
│   ├── claude-code-sdk.md     # SDK reference
│   └── prd.md                 # Product requirements draft
├── backend/                   # FastAPI sidecar (uv project)
│   ├── pyproject.toml
│   └── src/palette_sidecar/
├── apps/
│   └── mac/
│       └── PaletteApp/        # SwiftUI summon window prototype (SwiftPM)
├── assets/
│   └── claude-cli/            # Bundled Claude CLI runtime
├── AGENTS.md                  # Contributor guidelines
└── CLAUDE.md                  # Agent operating instructions
```

## Contributing

Current focus areas:
1. Select core architecture stack and IPC strategy
2. Prototype native windowing and command palette flows
3. Define distribution, update, and permission-handling pipelines

## License

TBD

---

*This repository exists to design and ship a native macOS application that can fully leverage the Claude Code SDK without compromise.*
