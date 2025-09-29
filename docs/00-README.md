# Familiar Documentation

**Navigation guide for the Familiar project documentation**

## Quick Start

1. **New to the project?** → Start with [../README.md](../README.md) for project overview
2. **Want to understand the architecture?** → Read [reference/architecture.md](reference/architecture.md)
3. **Building features?** → Check [implementation/](implementation/) guides
4. **Designing UI/UX?** → Explore [design/](design/) specifications
5. **Curious about the future?** → Browse [future/](future/) ideas

---

## Documentation Structure

### 📚 Reference (`reference/`)

Foundational knowledge and technical specifications:

- **[claude-code-sdk.md](reference/claude-code-sdk.md)** - Complete Claude Code SDK reference
  - Options, permissions, hooks, MCP servers
  - Python SDK patterns and examples
  - Headless mode and streaming

- **[swiftui-reference.md](reference/swiftui-reference.md)** - SwiftUI patterns for Familiar
  - Components, layout, state management
  - macOS-specific APIs

- **[architecture.md](reference/architecture.md)** *(TO BE CREATED)*
  - System design and component interaction
  - FastAPI sidecar + SwiftUI client pattern
  - Data flow and responsibility boundaries

---

### 🛠️ Implementation (`implementation/`)

Step-by-step guides for building features:

- **[steel-thread-v1.md](implementation/steel-thread-v1.md)** - V1 feature checklist
  - Onboarding flow
  - Backend sidecar setup
  - macOS app integration
  - QA and smoke tests

- **[auth-login-flow.md](implementation/auth-login-flow.md)** *(TO BE CREATED)*
  - Claude.ai OAuth-style authentication
  - API key fallback mode
  - Session management

- **[mcp-integration.md](implementation/mcp-integration.md)** *(TO BE CREATED)*
  - MCP server configuration
  - Tool namespace handling
  - Installation and lifecycle

- **[phased-enhancements.md](implementation/phased-enhancements.md)** *(COMING SOON)*
  - Phase 1: Claude Login Polish
  - Phase 2: Settings UX Overhaul
  - Phase 3: SDK Feature Exposure
  - Phase 4: Agent Visualization

---

### 🎨 Design (`design/`)

Visual and interaction design specifications:

- **[aesthetic-system.md](design/aesthetic-system.md)** - Hermetic magic design language
  - Color palette, typography, iconography
  - Deterministic sigils and rituals
  - Motion, sound, and accessibility
  - Mapping system state to visual metaphors

- **[agent-visualization.md](design/agent-visualization.md)** - Agent orchestration UI
  - Right sidebar architecture
  - Magical animations for agent lifecycle
  - Haiku-powered status summaries
  - Implementation phases and performance

- **[visual-improvements.md](design/visual-improvements.md)** *(TO BE CREATED)*
  - Consolidated visual polish tasks
  - Quick wins and design token system
  - Component improvements

---

### 🚀 Future (`future/`)

Exploratory ideas and long-term vision:

- **[narrative-magic-layer.md](future/narrative-magic-layer.md)** - Storytelling enhancements
- **[animated-companions.md](future/animated-familiar-companions.md)** - Character system
- **[creative-toolkit.md](future/creative-toolkit-magic.md)** - Extended capabilities
- **[exa-research.md](future/exa-research-integration.md)** - Research integration

---

## Documentation Principles

1. **Start with "Why"** - Explain the problem before the solution
2. **Show, Don't Just Tell** - Include code examples and diagrams
3. **Keep It Fresh** - Update docs alongside code changes
4. **Link Generously** - Connect related concepts across files
5. **Mark Status** - Tag sections as DRAFT, IMPLEMENTED, DEPRECATED

---

## Contributing to Docs

When adding new documentation:

- **Reference docs**: Timeless technical information
- **Implementation docs**: Step-by-step build guides with acceptance criteria
- **Design docs**: Visual specifications with rationale
- **Future docs**: Explorations that may become implementation plans

**File Naming**: Use lowercase with hyphens (e.g., `auth-login-flow.md`)

---

## Status Legend

- ✅ **IMPLEMENTED** - Feature is live in codebase
- 🚧 **IN PROGRESS** - Actively being worked on
- 📋 **PLANNED** - Scoped and ready for implementation
- 💭 **DRAFT** - Early exploration, subject to change
- 🗄️ **ARCHIVED** - Historical reference only

---

**Last Updated**: September 29, 2025