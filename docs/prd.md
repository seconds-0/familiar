Alex, here is a practical, opinionated implementation plan for a blazing‑fast “Command Palette for Claude Code” that you can summon anywhere on your computer. It is structured in phases so you can ship a crisp v1, then layer in power features without compromising UX or safety.

I’m assuming macOS first for speed and fit-and-finish, with a portable backend and an optional cross‑platform UI path later.

---

## 0) Product shape and first principles

**Non‑negotiables for UX**

* Summon instantly with a global shortcut. Do not hijack ⌘C since that collides with copy. Use ⌥Space by default, and let users remap. Keep the window lightweight, focused, and always centered. Use subtle spring animations later, not in v1.
* Latency kills trust. We stream tokens as they arrive. We never block on long tool runs: show progress and affordances to pause, cancel, or “force continue.”
* Safety is visible. Before Claude can touch files or shell, the user must explicitly allow the specific tool or the whole MCP server. Show a one‑line, human‑readable explanation every time.
* Claude Code is the engine. We build on the **Claude Code SDK for Python** with the same harness, tools, permissions, hooks, memory, subagents, and MCP. This is the fastest path to serious capability. ([Claude Docs][1])

**Why this is not “just Claude Desktop”**

* Claude Desktop is an excellent MCP host with one‑click extensions and an ecosystem, but it is a general chat client. It does not expose the full Claude Code harness, slash‑commands, or hook lifecycle in your own bespoke UI. Your app is a specialized command surface glued to the SDK for deep tool control and custom orchestration. Use Desktop for end user chat and connectors, your app for “do things to my computer with precise guardrails and speed.” ([Anthropic][2])

---

## 1) Architecture overview

**Process model**

* **macOS front end (SwiftUI)**: ultra‑fast summon window, token stream viewer, approval modals, settings, 1‑click MCP installer UI.
* **Local sidecar (Python FastAPI)**: owns a persistent `ClaudeSDKClient` session, streams events to UI via SSE, brokers permission prompts via SDK **hooks**, manages MCP servers, stores settings, and later memory. Uses **uv** for dependency management. ([Claude Docs][3])

**Claude Code features we rely on**

* **SDK primitives**: `query()` for one‑shot, `ClaudeSDKClient` for persistent sessions and streaming input, `ClaudeCodeOptions` for tools, `PermissionMode`, and cwd.
* **Hooks**: `PreToolUse`, `PostToolUse`, `Stop`, `UserPromptSubmit`, `SessionStart` to implement approvals, policy, “force continue,” and context injection.
* **MCP support**: local stdio servers and remote HTTP/SSE servers; namespaced tools like `mcp__github__get_issue`.
* **Slash commands** and **CLAUDE.md memory** compatibility. ([Claude Docs][3])

**One‑click MCP installs**

* Teach the app to install MCP servers from a manifest. Claude Desktop’s “Desktop Extensions” `.mcpb` bundles are a good model to emulate. We can start simple: a JSON manifest that declares server type, command, args, and any user config. Later, add `.mcpb` compatibility. ([Anthropic][2])

---

## 2) Repo structure

```
familiar/
├── apps/
│   └── mac/
│       ├── PaletteApp.xcodeproj
│       ├── PaletteApp/              # SwiftUI app target
│       │   ├── App.swift
│       │   ├── UI/
│       │   │   ├── PaletteWindow.swift
│       │   │   ├── StreamView.swift
│       │   │   ├── ApprovalsSheet.swift
│       │   │   ├── SettingsView.swift
│       │   │   └── MCPDirectoryView.swift
│       │   ├── Services/
│       │   │   ├── EventSource.swift     # SSE client
│       │   │   └── SidecarClient.swift   # REST client
│       │   └── Support/
│       │       ├── Hotkey.swift
│       │       └── Keychain.swift
│       └── Package.resolved
├── backend/
│   ├── pyproject.toml                 # uv project
│   ├── uv.lock
│   └── src/palette_sidecar/
│       ├── api.py                     # FastAPI app
│       ├── claude_service.py          # SDK client + hooks
│       ├── mcp_registry.py            # install/list/start MCPs
│       ├── permissions.py             # broker for approvals
│       ├── memory_store.py            # v2 persistent memory
│       └── models.py                  # pydantic types
├── mcp/
│   ├── manifests/                     # lightweight JSON manifests
│   └── examples/                      # sample servers
├── .github/workflows/
│   ├── mac-build.yml
│   └── backend-ci.yml
└── docs/
    ├── DESIGN.md
    └── SECURITY.md
```

---

## 3) Tooling and environment

* **Python**: uv for everything (env, deps, scripts). Add ruff and mypy.
  `uv add fastapi uvicorn anyio pydantic sse-starlette claude-code-sdk` ([Astral Docs][4])
* **macOS app**: Xcode 16, Swift 5.10, Swift Package **KeyboardShortcuts** for global hotkeys. ([GitHub][5])
* **Build**: GitHub Actions macOS runner to produce notarized DMG, and backend wheel.
* **Runtime prerequisites**: install the **Claude Code CLI** and Node once on first launch of the sidecar, or detect and guide the user. `npm i -g @anthropic-ai/claude-code`. ([GitHub][6])

---

## 4) Phase plan

### Phase 1 – Steel Thread V1 (polished end-to-end slice)

**Definition**

The Steel Thread is the smallest, fully polished workflow that proves the product vision: install → summon → ask → tool action → human-reviewed result → exit. V1 is done when a new user can:

1. Install the macOS app bundle and Python sidecar with one guided setup (DMG or signed zip is acceptable for V1).
2. Launch a menu-bar resident app that registers a global shortcut (`⌥Space` default) and shows status when the sidecar is reachable.
3. Summon the palette, enter freeform text, and watch Claude Code stream tokens in under 250 ms perceived latency.
4. Approve a single guarded file action (e.g., append text to a scratch file inside the chosen workspace) via the PreToolUse sheet.
5. View the final assistant answer with the tool result summarized inline and dismiss the window without residual dialogs or crashes.

**Deliverables**

- Notarized macOS app bundle with auto-launching sidecar (launchd helper is optional; a post-install prompt to start the sidecar is acceptable).
- Python sidecar shipping with `uv` lockfile, FastAPI app, `/query`, `/approve`, `/health`, and one whitelisted `Write` tool call bound to a demo workspace.
- SwiftUI UI/UX: summon panel, streaming transcript, approval sheet, and final success state.
- Installer onboarding doc (`docs/steel-thread.md` or an expanded section in README) describing prerequisites (Node, Claude CLI) and the happy-path walkthrough.
- Smoke test script that exercises install → summon → query → approved file mutation (manual QA checklist is acceptable while automation lands).

**Success Metrics for V1**

- Time from fresh clone to working Steel Thread ≤ 15 minutes when following the documented steps.
- Token stream visible within 1 second of pressing return on a query (M2 baseline).
- File action writes to the intended sandbox path, persists to disk, and surfaces a diff/summary in the transcript.
- Palette toggles cleanly and global shortcut can be rebound without restart.

**Scope Guardrails**

- No MCP manifests, slash commands, or multi-tool orchestration in V1.
- Single Claude model (for example, `claude-3.5-sonnet`) hard-coded; model picker deferred to Phase 2.
- File action limited to the demo directory; no arbitrary filesystem browsing yet.
- Manual install of Claude Code CLI is fine if the setup flow clearly prompts for it.

**Implementation Outline**

- Harden onboarding: sidecar startup on first launch, API key capture, verification ping, workspace directory selection, and writing a `.steel-thread-workspace` marker file.
- Wire `PreToolUse` hook to surface a modal summarizing the impending file change and require explicit approval before executing.
- Return `ToolResultBlock` content and render a “change applied” card with file path and snippet in the transcript.
- Add graceful shutdown: quitting the menu-bar app stops the sidecar and releases the global shortcut.

**Core backend: FastAPI + Claude Code SDK**

```python
# backend/src/palette_sidecar/claude_service.py
import anyio
from typing import AsyncIterator
from claude_code_sdk import ClaudeSDKClient, ClaudeCodeOptions, AssistantMessage, TextBlock

class ClaudeSession:
    def __init__(self, cwd: str | None = None):
        self.options = ClaudeCodeOptions(
            cwd=cwd,
            # start with no tools; we will gate tools later
            allowed_tools=[], 
            permission_mode="ask"   # be conservative initially
        )
        self.client: ClaudeSDKClient | None = None

    async def start(self) -> None:
        self.client = ClaudeSDKClient(options=self.options)
        await self.client.connect()

    async def stream(self, prompt: str) -> AsyncIterator[str]:
        assert self.client is not None
        await self.client.query(prompt)
        async for msg in self.client.receive_response():
            if isinstance(msg, AssistantMessage):
                for block in msg.content:
                    if isinstance(block, TextBlock):
                        yield block.text
```

```python
# backend/src/palette_sidecar/api.py
from fastapi import FastAPI
from fastapi.responses import StreamingResponse
from palette_sidecar.claude_service import ClaudeSession

app = FastAPI()
session = ClaudeSession()

@app.on_event("startup")
async def _startup():
    await session.start()

@app.post("/query")
def query(payload: dict):
    prompt = payload["prompt"]

    async def eventgen():
        async for chunk in session.stream(prompt):
            yield f"data: {chunk}\n\n"   # SSE

    headers = {"Cache-Control": "no-cache", "Connection": "keep-alive"}
    return StreamingResponse(eventgen(), media_type="text/event-stream", headers=headers)
```

The SDK gives us persistent sessions and streaming. We render plain text right away. Later we’ll parse structured messages and tool use. ([Claude Docs][3])

**macOS global hotkey and summon window**

```swift
// apps/mac/PaletteApp/Support/Hotkey.swift
import KeyboardShortcuts

extension KeyboardShortcuts.Name {
    static let summon = Self("summonAssistant")
}

// Set a sensible default like Option+Space
// In App.init(): KeyboardShortcuts.setShortcut(.init(.space, modifiers: [.option]), for: .summon)
```

```swift
// apps/mac/PaletteApp/UI/PaletteWindow.swift
import SwiftUI
import KeyboardShortcuts

final class PaletteWindowController: NSWindowController {
    static let shared = PaletteWindowController()
    private init() {
        let hosting = NSHostingController(rootView: PaletteView())
        let panel = NSPanel(contentViewController: hosting)
        panel.titleVisibility = .hidden
        panel.isFloatingPanel = true
        panel.hidesOnDeactivate = false
        panel.styleMask = [.nonactivatingPanel, .fullSizeContentView]
        panel.level = .statusBar
        super.init(window: panel)
    }
    required init?(coder: NSCoder) { fatalError() }
    func toggle() {
        guard let w = window else { return }
        if w.isVisible { w.orderOut(nil) } else {
            w.center(); w.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
        }
    }
}

struct PaletteView: View {
    @State private var input = ""
    @State private var output = ""
    var body: some View {
        VStack(spacing: 12) {
            TextField("Ask Claude Code…", text: $input, onCommit: run)
                .textFieldStyle(.roundedBorder)
            ScrollView { Text(output).textSelection(.enabled).font(.system(.body, design: .monospaced)) }
        }
        .padding(16)
        .frame(width: 680, height: 420)
        .onAppear {
            KeyboardShortcuts.onKeyUp(for: .summon) { PaletteWindowController.shared.toggle() }
        }
    }
    func run() {
        SidecarClient.shared.stream(prompt: input) { token in
            output.append(token)
        }
    }
}
```

**API key UI**

* Settings has “Anthropic API key” with “Test” button that does a dry call. SDK and docs expect `ANTHROPIC_API_KEY` or provider envs for Bedrock or Vertex. Store secrets in the Keychain. ([Claude Docs][1])

**Result**
A Spotlight‑like window that streams responses from a persistent Claude Code session. Zero tool use, zero surprises, very fast.

---

### Phase 2 - Tools and permissioning

**Goals**

* Add tool power with visible guardrails.
* Implement **PreToolUse** and **PostToolUse** hooks so the sidecar can ask the UI for permission before running Bash, Edit, MultiEdit, Write, or MCP tools.
* Add a clean approval sheet with “allow once,” “always allow this tool,” or “deny.”

**Hooks design (SDK supports Python functions as hooks)**

* When the SDK is about to run a tool, our PreToolUse hook fires. We enqueue a permission request, suspend until UI answers, then return `permissionDecision` `allow` or `deny`.
* We can also immediately block specific commands or directories, and add auto‑feedback for Claude when blocked.

```python
# backend/src/palette_sidecar/permissions.py
import asyncio
from dataclasses import dataclass
from typing import Dict

@dataclass
class Pending:
    fut: asyncio.Future[str]
    payload: dict

class PermissionBroker:
    def __init__(self) -> None:
        self._pending: Dict[str, Pending] = {}

    def request(self, req_id: str, payload: dict) -> asyncio.Future[str]:
        fut = asyncio.get_event_loop().create_future()
        self._pending[req_id] = Pending(fut, payload)
        return fut

    def answer(self, req_id: str, decision: str) -> None:
        self._pending.pop(req_id).fut.set_result(decision)

broker = PermissionBroker()
```

```python
# backend/src/palette_sidecar/claude_service.py (hooks wired into options)
from claude_code_sdk import HookMatcher

async def pre_tool_use(input_data, tool_use_id, context):
    tool = input_data["tool_name"]
    args = input_data["tool_input"]
    req_id = tool_use_id
    fut = broker.request(req_id, {"tool": tool, "args": args})
    decision = await fut          # "allow" | "deny" | "ask"
    return {
        "hookSpecificOutput": {
            "hookEventName": "PreToolUse",
            "permissionDecision": decision,
            "permissionDecisionReason": f"User decision for {tool}",
        }
    }

self.options = ClaudeCodeOptions(
    # …
    allowed_tools=["Read", "Write", "Edit", "MultiEdit", "Bash"],  # plus MCPs later
    permission_mode="ask",
    hooks={"PreToolUse": [HookMatcher(matcher="*", hooks=[pre_tool_use])]}
)
```

Hook semantics and JSON shape come straight from Anthropic’s hook reference. Use `permissionDecision` fields, not the older `approve/block`. Exit code 2 is a hard block. The `Stop` hook can force Claude to keep going. ([Claude Docs][7])

**UI approval sheet**

* Show tool name, human‑readable summary, working directory, preview for file edits if available, and “copy command” for Bash.
* Store “always allow” as a policy map keyed by tool or fully‑qualified MCP tool name like `mcp__github__list_prs`. ([Claude Docs][8])

---

### Phase 3 - MCP servers and “1‑click” installs

**Goals**

* Built‑in directory that lists known servers with “Install” and “Connect.”
* Support local **stdio** servers and remote **HTTP/SSE** servers, with token storage.
* Our manifest: keep it simple now, adopt `.mcpb` later.

**Minimal manifest example**

```json
{
  "id": "github",
  "title": "GitHub MCP",
  "transport": "stdio",
  "command": "npx",
  "args": ["-y", "@modelcontextprotocol/server-github"],
  "env": { "GITHUB_TOKEN": "${secret:github_token}" },
  "tools_whitelist": ["mcp__github"]   // approve all github tools when toggled
}
```

**Remote server config example**

```json
{
  "id": "jira-remote",
  "transport": "sse",
  "url": "https://jira-mcp.example.com/sse",
  "headers": { "Authorization": "Bearer ${secret:jira_token}" }
}
```

**Sidecar wiring**

```python
# backend/src/palette_sidecar/mcp_registry.py
from claude_code_sdk import McpStdioServerConfig, McpSSEServerConfig

def to_mcp_config(manifest: dict):
    if manifest["transport"] == "stdio":
        return McpStdioServerConfig(command=manifest["command"], args=manifest.get("args", []), env=manifest.get("env", {}))
    if manifest["transport"] == "sse":
        return McpSSEServerConfig(url=manifest["url"], headers=manifest.get("headers", {}))
    raise ValueError("Unsupported transport")
```

Expose a toggle in Settings that appends these to `ClaudeCodeOptions.mcp_servers` and, if opted‑in, pre‑approves `allowed_tools` for the server namespace `mcp__server`. The Python SDK defines these config types. ([Claude Docs][3])

**.mcpb support (later in the phase)**

* The Desktop Extensions spec describes `.mcpb` zip bundles with a `manifest.json`, server files, and dependencies. We can support “Install from .mcpb” by unpacking into our data dir, substituting `${__dirname}` in args, and launching with stdio. The spec is public. ([Anthropic][2])

---

### Phase 4 - Canvas/file viewer, diffs, and slash commands

**Goals**

* Add a right‑side “canvas” panel that renders artifacts, previews diffs, and shows file trees for edits.
* Surface **slash commands** from project and user scope to autocomplete after typing `/`.
* Display memory files and let the user open or edit `CLAUDE.md` quickly.

Slash commands live under `.claude/commands` and `~/.claude/commands` with frontmatter and arguments. We can list them and offer completion. ([Claude Docs][8])

**Memory**

* Claude Code supports multiple memory locations and import syntax. Provide toggles in Settings to display and open these files or create them if missing. ([Claude Docs][9])

---

### Phase 5 - “Continue until done” supervisor harness

**Goals**

* One Claude Code “worker” focuses on the task with tools.
* A second “supervisor” watches for the worker to stop too early.
* If the worker tries to stop but criteria are not met, the **Stop** hook returns a JSON decision to block stoppage and provides a reason or next step.

**Stop hook sketch**

```python
async def stop_hook(input_data, *_):
    # Inspect transcript path for unresolved TODOs, failing tests, or incomplete plan items
    unresolved = await analyze_transcript(input_data["transcript_path"])
    if unresolved:
        return {"decision": "block", "reason": f"Not done: {', '.join(unresolved)}. Continue."}
    return {}

self.options.hooks["Stop"] = [HookMatcher(matcher="*", hooks=[stop_hook])]
```

The official hook semantics let a Stop hook block termination and supply a “reason” for Claude to proceed. This is the right lever for your “just keep going” behavior, without duct‑taping extra prompts. ([Claude Docs][7])

---

### Phase 6 - Accumulating memory and recall

**Goals**

* Add a lightweight local memory store for facts and preferences that do not belong in CLAUDE.md.
* Keep it privacy‑first: local SQLite with page‑level encryption, the key in Keychain.
* Build a SessionStart hook to inject a synthesized context snippet assembled from recent, high‑signal memories. Show an on‑screen toggle to include or suppress it per session. ([Claude Docs][7])

---

### Phase 7 - Polishing the “instantaneous” feel

* Microanimations on open/close and token stream line breaks.
* Optimistic “typing” bubble while establishing the SSE.
* Zero‑jank text layout using monospaced fonts, soft wrap, and preserved whitespace.
* Keyboard‑only flow: ⌘K to focus, ⌘⇧K to clear, ↑ to edit the last query, ⌘. to cancel the current turn, ⌘↩ to force continue.

---

## 5) Implementation details the team will ask for

### Backend dependencies (uv)

`pyproject.toml` highlights:

```toml
[project]
name = "palette-sidecar"
version = "0.1.0"
requires-python = ">=3.10"
dependencies = [
  "fastapi>=0.115",
  "uvicorn[standard]>=0.30",
  "anyio>=4.4",
  "pydantic>=2.7",
  "sse-starlette>=1.8",
  "claude-code-sdk>=0.0.23",
  "python-dotenv>=1.0"
]

[tool.ruff]
line-length = 100

[tool.mypy]
strict = true
```

Use `uv run uvicorn palette_sidecar.api:app --host 127.0.0.1 --port 8765 --reload` in dev. ([Astral Docs][4])

### Sidecar REST surface

* `POST /query {prompt, sessionId?}` -> SSE stream of events
* `POST /approve {requestId, decision}` -> resolves a pending PreToolUse
* `GET /health`
* `GET /mcp` list configured servers
* `POST /mcp/install` with manifest or `.mcpb`
* `POST /settings` set cwd, model, permission defaults, API key

### Mapping SDK messages to UI

* `AssistantMessage` with `TextBlock` -> stream tokens.
* `ToolUseBlock` -> show “Claude wants to run ….”
* `ToolResultBlock` -> append “Result” sections, attach file diffs or bash output.
  The Python SDK types enumerate these blocks. ([Claude Docs][3])

### macOS pieces

* **Global hotkey**: Sindre Sorhus’s `KeyboardShortcuts` supports user‑customizable global shortcuts, App Store compatible. ([GitHub][5])
* **UI**: use `NSPanel` non‑activating floating panel for the summon window to avoid stealing focus too aggressively.
* **SSE**: simple `URLSessionStreamTask` or a lightweight EventSource client to parse `data:` lines.
* **Keychain**: store tokens with `SecItemAdd`/`SecItemCopyMatching`.

---

## 6) Security and safety model

* Default to **no tools allowed**. The first time a tool is invoked, ask. Persist user policies by tool or MCP namespace. Slash command invocations inherit the same policy. ([Claude Docs][8])
* Restrict Bash to a working directory unless explicitly expanded. Deny dangerous patterns in PreToolUse (rm -rf without path safeguards, curl|bash, etc.) with automatic feedback. ([Claude Docs][7])
* Show a clear “who pays” indicator and token/cost meters. If you ever use headless JSON output or Result messages with costs, surface those numbers. ([Claude Docs][10])
* All secrets in Keychain. No cloud storage by default.

---

## 7) Comparison with Claude Desktop, explicitly

* **Desktop strengths**: one‑click `.mcpb` extensions, an official directory, OS keychain integration, and a huge and growing connectors ecosystem. It is a great MCP host for general users. The engineering post details the extension format and secure secrets handling. ([Anthropic][2])
* **Your app strengths**: a purpose‑built command surface married to **Claude Code**. You use SDK‑level **hooks**, **slash commands**, **subagents**, and **memory** in your own UX, plus aggressive streaming and custom approval logic. The SDK is designed to expose exactly these knobs. ([Claude Docs][1])
* **Overlap**: both can connect to local and remote MCP servers. Desktop’s one‑click is deeper today; you can interoperate by supporting `.mcpb`. ([Model Context Protocol][11])
* **Conclusion**: you are not reinventing Desktop. You are shipping a Claude Code‑first, low‑latency “do‑things” palette with strong approvals and IDE‑adjacent ergonomics.

---

## 8) What to build next for v2 and beyond

* **Canvas panel** for artifacts, images, preview of edits, and file browsing.
* **Accumulating memory** summarized into CLAUDE.md at SessionStart. ([Claude Docs][9])
* **Agent harness** with a dedicated supervisor via `Stop` hook and policies. ([Claude Docs][7])
* **.mcpb** install flow and registry integration. ([Anthropic][2])
* **Optional cross‑platform UI** with Tauri once macOS is stellar.

---

## 9) References to wire into issues and code comments

* Claude Code SDK overview and options, including permissions, memory, and MCP: Anthropic docs. ([Claude Docs][1])
* Python SDK reference: functions, types, `ClaudeSDKClient`, tool decorators, and MCP configs. ([Claude Docs][3])
* Hooks reference: JSON contracts for PreToolUse, PostToolUse, Stop, and exit code semantics. ([Claude Docs][7])
* Slash commands reference: locations, frontmatter, MCP slash commands, and permissions. ([Claude Docs][8])
* Headless mode JSON and streaming formats (useful for cost display patterns, not required for SDK path). ([Claude Docs][10])
* GitHub repo for the Python SDK and prerequisites (Python 3.10+, Node, and the Claude Code CLI). ([GitHub][6])
* Model Context Protocol concepts for local stdio vs remote SSE/HTTP servers. ([Model Context Protocol][11])
* Desktop Extensions architecture and `.mcpb` manifest example. ([Anthropic][2])
* Swift global hotkeys library. ([GitHub][5])
* uv package manager docs. ([Astral Docs][4])

---

## 10) Opinionated checklist to start the repo

1. Initialize backend with uv. Add FastAPI, `claude-code-sdk`, ruff, mypy. Wire `api.py` and a basic `/query` SSE.
2. Add `claude_service.py` with a persistent `ClaudeSDKClient`. Verify streaming.
3. Build SwiftUI shell with a floating NSPanel, global hotkey, and SSE client.
4. Add Settings with Keychain‑backed API key, cwd picker, model dropdown.
5. Implement PreToolUse broker and the Approvals sheet. Tight loop: deny by default, allow once, allow always.
6. Land manifest‑driven MCP config for stdio and SSE servers, starting with filesystem and GitHub.
7. Add slash command autocomplete and memory file shortcuts.
8. Ship a notarized DMG.

When you want to stretch into “self‑constructing tools,” take advantage of SDK in‑process MCP tools via the `@tool` decorator. You can let Claude author new tools under supervision, bundle them into a mini server with `create_sdk_mcp_server`, and make them available immediately. Keep a strict PreToolUse policy when generating tools on the fly. ([GitHub][6])

If you want, I can translate this into a set of GitHub issues with dependency ordering, copy‑pasteable commands, and the first unit tests for the sidecar.

[1]: https://docs.anthropic.com/en/docs/claude-code/sdk "Overview - Claude Docs"
[2]: https://www.anthropic.com/engineering/desktop-extensions "Claude Desktop Extensions: One-click MCP server installation for Claude Desktop \ Anthropic"
[3]: https://docs.claude.com/en/docs/claude-code/sdk/sdk-python "Python SDK reference - Claude Docs"
[4]: https://docs.astral.sh/uv/?utm_source=chatgpt.com "uv - Astral Docs"
[5]: https://github.com/sindresorhus/KeyboardShortcuts?utm_source=chatgpt.com "sindresorhus/KeyboardShortcuts"
[6]: https://github.com/anthropics/claude-code-sdk-python "GitHub - anthropics/claude-code-sdk-python"
[7]: https://docs.claude.com/en/docs/claude-code/hooks "Hooks reference - Claude Docs"
[8]: https://docs.claude.com/en/docs/claude-code/slash-commands "Slash commands - Claude Docs"
[9]: https://docs.claude.com/en/docs/claude-code/memory "Manage Claude's memory - Claude Docs"
[10]: https://docs.claude.com/en/docs/claude-code/sdk/sdk-headless "Headless mode - Claude Docs"
[11]: https://modelcontextprotocol.io/docs/concepts/architecture "Architecture overview - Model Context Protocol"
