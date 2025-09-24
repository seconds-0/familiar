# PRD: Claude Control (Raycast + Local Helper)

## Vision

One hotkey, native Raycast UI, real actions. A local companion Helper performs privileged operations (Claude Code SDK, shell, file edits); the Raycast command orchestrates UX, safety, and distribution.

## Hero Experience

```
Cmd+Cmd → "Find that CSV on my desktop about Q3 sales"
         → [Assistant searches, finds, and displays it]

         "What's in there?"
         → [Assistant analyzes and summarizes the data]

         "Write a Python script to visualize this"
         → [Assistant creates and runs the script]

         "Perfect, deploy this to the team dashboard"
         → [Assistant handles the entire deployment]
```

No commands to learn. No configuration needed. Just natural language and things happen.

## Problem

Raycast’s runtime is sandboxed and short‑lived; it doesn’t reliably support spawning external processes. Claude Code’s CLI/SDK expects subprocesses for actions and MCP servers. We need a split architecture.

## Goals
- Quick‑open Raycast UI with streaming and persistent sessions
- Reliable action‑taking (read/edit/multi‑edit, grep/glob, bash) via a local Helper
- One‑click install wizard from Raycast (download → verify → open installer → handshake)
- Auth: “Sign in with Claude” (via Helper) or API key (within Raycast)
- Clear, granular Allowed Paths and confirmations; safe by default

## Non‑Goals
- Running long‑lived subprocesses inside Raycast
- Exposing the Helper beyond localhost / domain socket

## User Flows
### First Run
1) Open command → wizard detects no Helper
2) Install Helper → Raycast downloads notarized installer to `environment.supportPath`, verifies SHA‑256, `open()` installer
3) Raycast polls `/health`, then performs handshake (local auth token)
4) Choose auth: “Sign in with Claude” (Helper opens browser) or “Use API key” (in Raycast)
5) Select Allowed Paths → POST to Helper `/config/allowed-paths`
6) Ready

### Daily Use
Cmd+Cmd → type instruction → Raycast streams model output and tool plans → shows diffs/confirmations → Helper applies changes and streams logs → success/failure summary with follow‑up actions.

### Failure Modes
- Helper down → “Start Helper”, “Reinstall”, or “Limited mode (read/edit/grep in‑process)”
- Version mismatch → prompt to update Helper

## Architecture

Raycast Command (UI, install, auth UI, limited mode)
↔ Local Helper (HTTP/SSE on 127.0.0.1 or Unix socket; auth token)

Helper endpoints (MVP):
- `GET /health`
- `POST /auth/start` → { url }
- `GET /auth/status`
- `POST /query` (SSE stream of SDK events)
- `POST /files/read`, `POST /files/edit`, `POST /files/diff`
- `POST /bash/exec` (streamed stdout/stderr)
- `POST /config/allowed-paths`, `GET /config`
- `POST /shutdown`

Security:
- Signed/notarized Helper, pinned SHA‑256 in extension
- Local auth token; per‑request verification
- Server‑side Allowed Paths enforcement; dangerous ops require explicit confirm

## Capabilities
- Read/Write/Edit/MultiEdit with diffs and preview
- Grep/Glob/Search
- Bash (streamed, cancellable)
- Claude Code SDK sessions and tools via Helper
- Limited mode without Helper: in‑process read/edit/grep only

## Install UX
- Inline wizard in Raycast (List/Detail screens)
- Download to `environment.supportPath`, SHA‑256 verify
- Launch installer via `open()`; poll Helper `/health`
- Handshake, auth, Allowed Paths setup

## Auth
- Sign in with Claude: Helper runs SDK login; tokens/cookies remain in Helper
- API key: stored in Raycast Preferences; used for direct API fallback if Helper unavailable

---

## Milestones
1) Wizard + download/verify/open + health/handshake + limited mode
2) Helper MVP: `/query`, `/files.read/edit/diff`, `/bash.exec`; Allowed Paths
3) Auth flows (Claude login + API key); confirmations & diffs
4) Polishing: updates, error UX, logs, docs, store listing

## Risks & Mitigations
- Installer friction → notarized build, clear copy, retry flows
- AV/firewall blocks → localhost/socket transport; minimal ports
- Version skew → health reports versions; guided update

Built on Claude Code TypeScript SDK with Raycast's native APIs. ([Claude Docs][1])

### Authentication Flow

Two paths, both invisible after first setup:

```typescript
// Preferred: Claude.ai login for Max/Pro users
// Triggered automatically on first use
const mcpServers = await readUserScopeMcpServers(prefs);
for await (const m of query({
  prompt: "/status",  // Auto-triggers login if needed
  options: {
    includePartialMessages: true,
    env: process.env
  }
})) {
  await onMessage(m);
}

// Fallback: API key (stored securely in Raycast Preferences)
const env = prefs.anthropicApiKey
  ? { ANTHROPIC_API_KEY: prefs.anthropicApiKey }
  : process.env;
```

### The Main Chat Implementation

```typescript
import {
  Action, ActionPanel, List, confirmAlert, showToast, Toast, LocalStorage, environment
} from "@raycast/api";
import { useEffect, useState, useRef } from "react";
import {
  query, type SDKMessage, type SDKSystemMessage, type SDKPartialAssistantMessage, type PermissionResult
} from "@anthropic-ai/claude-code";

export default function Assistant() {
  const [searchText, setSearchText] = useState("");
  const [isLoading, setIsLoading] = useState(false);
  const [messages, setMessages] = useState<Message[]>([]);
  const [sessionId, setSessionId] = useState<string | undefined>();
  const streamBuffer = useRef("");

  // Auto-restore conversation for this directory
  useEffect(() => {
    const cwd = process.cwd();
    void LocalStorage.getItem<string>(`session_${cwd}`).then(setSessionId);
  }, []);

  async function sendMessage() {
    const text = searchText.trim();
    if (!text) return;

    setSearchText("");
    setMessages(p => [...p, { role: "user", text, id: crypto.randomUUID() }]);
    streamBuffer.current = "";
    setIsLoading(true);

    try {
      const mcpServers = await getAutoConfiguredMCP();  // Auto-detect environment
      for await (const m of query({
        prompt: text,
        options: {
          includePartialMessages: true,
          resume: sessionId,
          permissionMode: await getSmartPermissionMode(),  // Progressive trust
          model: "default",  // Let SDK choose
          canUseTool: smartPermissionHandler,  // Only prompt when needed
          mcpServers,
          env: await getAuthEnvironment()
        }
      })) {
        await handleStreamingMessage(m);
      }
    } catch (e) {
      await showToast({ style: Toast.Style.Failure, title: "Error", message: String(e) });
    } finally {
      setIsLoading(false);
    }
  }

  // Beautiful streaming chat UI
  return (
    <List
      isLoading={isLoading}
      searchText={searchText}
      onSearchTextChange={setSearchText}
      searchBarPlaceholder="What do you want me to do?"
    >
      {messages.map(m => (
        <List.Item
          key={m.id}
          title={m.role === "user" ? "You" : "Assistant"}
          subtitle={m.text}
          accessories={m.actions?.map(a => ({ text: a, tooltip: "Suggested action" }))}
        />
      ))}
    </List>
  );
}
```

## Smart Permission System

Progressive trust building with minimal friction: ([Claude Docs][5])

```typescript
async function smartPermissionHandler(toolName: string, input: any): Promise<PermissionResult> {
  const trustLevel = await getTrustLevel(process.cwd());

  // Auto-approve safe operations
  if (toolName === "Read" || toolName === "Bash" && isSafeCommand(input)) {
    return { behavior: "allow", updatedInput: input };
  }

  // Auto-approve in trusted projects after initial success
  if (trustLevel === "trusted" && !isDangerous(toolName, input)) {
    return { behavior: "allow", updatedInput: input };
  }

  // Show inline preview for edits
  if (toolName === "Edit" || toolName === "Write") {
    const preview = await generatePreview(input);
    const ok = await confirmAlert({
      title: "Apply this change?",
      message: preview,  // Shows diff
      primaryAction: { title: "Apply", style: Action.Style.Regular },
      dismissAction: { title: "Skip" }
    });

    if (ok) {
      await incrementTrust(process.cwd());
      return { behavior: "allow", updatedInput: input };
    }
  }

  return { behavior: "deny", message: "Skipped" };
}
```

## Auto-Configured MCP

Detects environment and configures automatically: ([Claude Docs][2])

```typescript
async function getAutoConfiguredMCP() {
  const hasNpm = await exists("package.json");
  const hasPython = await exists("requirements.txt");
  const hasGit = await exists(".git");

  const servers: Record<string, any> = {};

  // Always enable filesystem access
  servers.filesystem = {
    type: "stdio",
    command: "npx",
    args: ["-y", "@modelcontextprotocol/server-filesystem"],
    env: { ALLOWED_PATHS: process.cwd() }  // Scoped to current directory
  };

  // Add search if available
  if (process.env.BRAVE_API_KEY) {
    servers.braveSearch = {
      type: "sse",
      url: "https://api.search.brave.com/mcp/sse",
      headers: { "X-API-KEY": process.env.BRAVE_API_KEY }
    };
  }

  return servers;
}
```

## Session & State Management

Per-directory conversation memory:

```typescript
// Save session per working directory
async function saveSession(sessionId: string) {
  const cwd = process.cwd();
  await LocalStorage.setItem(`session_${cwd}`, sessionId);

  // Track trust level
  const trust = await LocalStorage.getItem<number>(`trust_${cwd}`) || 0;
  await LocalStorage.setItem(`trust_${cwd}`, trust);
}

// Progressive trust building
async function incrementTrust(path: string) {
  const current = await LocalStorage.getItem<number>(`trust_${path}`) || 0;
  await LocalStorage.setItem(`trust_${path}`, current + 1);

  if (current + 1 === 3) {
    await showToast({
      style: Toast.Style.Success,
      title: "This project is now trusted",
      message: "Future edits will be faster"
    });
  }
}
```

## Manifest Configuration

```json
{
  "raycast": {
    "schemaVersion": 1,
    "title": "AI Assistant",
    "description": "AI that can actually control your computer",
    "icon": "icon.png",
    "author": "you",
    "categories": ["Productivity", "Developer Tools"],
    "keywords": ["ai", "assistant", "claude", "automation"],
    "commands": [
      {
        "name": "assistant",
        "title": "AI Assistant",
        "subtitle": "Do anything with AI",
        "description": "Open the AI assistant that can control your computer",
        "mode": "view",
        "preferences": [
          {
            "name": "hotkey",
            "title": "Keyboard Shortcut",
            "description": "Global hotkey to open assistant",
            "type": "text",
            "default": "cmd+cmd",
            "required": false
          }
        ]
      }
    ],
    "preferences": [
      {
        "name": "authMethod",
        "title": "Authentication",
        "type": "dropdown",
        "data": [
          { "title": "Claude.ai (Recommended)", "value": "claudeai" },
          { "title": "API Key", "value": "api-key" }
        ],
        "default": "claudeai",
        "required": false
      },
      {
        "name": "anthropicApiKey",
        "title": "Anthropic API Key",
        "type": "password",
        "description": "Only if using API key auth",
        "required": false
      }
    ]
  }
}
```

## Advanced Features (Hidden from Users)

### File-Based Permission Rules

For power users who find the hidden settings: ([Claude Docs][9])

```json
// ~/.claude/settings.json (user discovers this naturally)
{
  "permissions": {
    "allow": ["Bash(git status)", "Read(./README.md)"],
    "deny": ["Read(./.env)", "Write(./production/**)"],
    "ask": ["Bash(npm run deploy:*)", "WebFetch"]
  }
}

// .claude/settings.local.json (project-specific)
{
  "permissions": {
    "allow": ["Write(./**)", "Bash(npm run *)"],
    "deny": ["Bash(rm -rf *)"]
  }
}
```

### MCP Server Expansion

Power users can add servers via hidden config:

```json
// ~/.claude/mcp.json (discovered by power users)
{
  "mcpServers": {
    "custom": {
      "type": "stdio",
      "command": "my-custom-server",
      "args": ["--mode", "production"]
    }
  }
}
```

---

# Deployment Strategy

## Launch Phases

### Phase 1: Core Magic (MVP)
- Single hotkey launch
- File operations (read, write, edit)
- Code execution (safe commands)
- Beautiful streaming UI

### Phase 2: Enhanced Intelligence
- Smart context detection
- Progressive trust system
- Inline previews and diffs
- Action suggestions

### Phase 3: Power Features
- Advanced MCP servers
- Custom workflows
- Team sharing
- Voice input

## Success Metrics

- **Activation**: 80% use within 1 hour of install
- **Retention**: 60% daily active after 1 week
- **Trust Building**: 50% reach "trusted" status in first project
- **Zero Config**: 90% never open preferences

## Success Metrics
- TTI < 1s to open command; wizard < 2 minutes typical
- > 95% task completion for read/edit/grep/bash on sample repos
- > 90% successful Helper installs post‑notarization

## Store Positioning
“Claude Control: a quick‑open Raycast assistant that actually acts. Install once, command everything.”

---

## References
- Raycast API: environment paths, open(), LocalStorage
- Claude Code SDK: sessions, events, tools (used in Helper)