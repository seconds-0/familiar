# PRD: AI Power Assistant for Raycast

## The Vision

**One hotkey. Infinite power. Zero friction.**

Command+Command opens an AI assistant that can actually control your computer. Not just talk about your files - open them, edit them, run them, deploy them. This is the AI assistant everyone thought ChatGPT would be.

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

## Core Problem

Every AI chat can talk about code and files. None can actually touch them. Developers copy-paste between ChatGPT and their editor. PMs screenshot errors to get help. Designers describe files they wish they could just show the AI.

This changes that. Your AI assistant lives in your computer, not in a browser tab.

## Key User Stories

**As anyone**, I hit Command+Command and type what I want done - find files, read CSVs, fix code, organize folders - and it just happens.

**As a developer**, I can say "fix the build errors" and watch as the assistant reads errors, edits files, and verifies the fix.

**As a PM**, I can say "summarize yesterday's commits" and get release notes without touching git.

**As a designer**, I can say "resize all these SVGs to 24x24" and it's done in seconds.

## The Magic: Zero Setup Required

### Installation (30 seconds)
1. Install from Raycast Store
2. Hit Command+Command
3. Type your first request
4. One-click auth if needed (Claude.ai or API key)
5. That's it. Forever.

No permission screens. No MCP configuration. No model selection. It just works.

## UX Principles

### 1. Invisible Intelligence
The assistant figures out what tools it needs. Users never see:
- File permissions dialogs (until needed)
- MCP server configuration
- Model selection
- Technical commands

### 2. Progressive Trust
- **First file read**: Always allowed
- **First file edit**: Shows preview, one-click approve
- **After 3 successful edits**: Auto-trust this project
- **Dangerous operations**: Always confirm with explanation

Trust indicator (subtle dot):
- 🟢 Reading/analyzing
- 🟡 Will modify (preview available)
- 🔴 System change (requires confirm)

### 3. Context Awareness
The assistant knows:
- Current directory
- Selected files in Finder
- Last terminal command
- Open project type (npm, Python, etc.)
- Previous conversations in this folder

## Core Features

### The Chat Window
- **Launch**: Command+Command (customizable)
- **Dismiss**: Escape (conversation persists)
- **Return**: Command+Command brings back exact state
- Beautiful Raycast-native UI with streaming responses

### Natural Language is Everything
```
"fix the build" → Runs build, sees errors, fixes them
"what's on port 3000" → Checks and can kill it
"make this csv pretty" → Converts to formatted table
"deploy this" → Knows your deployment process
"why is this slow" → Profiles and explains
"clean up downloads" → Organizes by type and date
```

### Inline Everything
- File contents render with syntax highlighting
- Images display inline when found/created
- Terminal output streams live
- Diffs preview before applying
- Charts/graphs render in chat

### Smart Actions
Based on conversation, suggested actions appear as pills:
- After error: [Fix This] [Debug] [Explain]
- After finding files: [Open] [Edit] [Delete]
- After writing code: [Run] [Test] [Save]

---

# Technical Architecture

## Core Integration

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

## Store Listing

**Title**: AI Assistant - Control Your Computer with Natural Language

**Description**:
The AI that actually does things. Find files, fix code, run scripts, organize folders - just type what you want done. No commands to learn, no setup required. Hit Cmd+Cmd and start.

**Screenshots**:
1. Natural conversation fixing code
2. Finding and analyzing files
3. Running scripts and seeing results inline

---

# References

All technical documentation preserved:

* Claude Code TypeScript SDK reference: `query`, `Options`, `PermissionMode`, `mcpServers`, message types, streaming, and `setPermissionMode`. ([Claude Docs][1])
* SDK guide for permissions: `canUseTool` and rules design. ([Claude Docs][5])
* SDK guide for MCP: stdio and SSE configurations and examples. ([Claude Docs][2])
* MCP spec and official docs. ([GitHub][11])
* Raycast Storage, Preferences, and Store review docs. ([Raycast API][4])
* Community reports on permission rules and in-process MCP stability. ([GitHub][10])

[1]: https://docs.claude.com/en/docs/claude-code/sdk/sdk-typescript "TypeScript SDK reference - Claude Docs"
[2]: https://docs.anthropic.com/en/docs/claude-code/sdk/sdk-mcp?utm_source=chatgpt.com "MCP in the SDK - Claude Docs"
[3]: https://developers.raycast.com/?utm_source=chatgpt.com "Raycast API: Introduction"
[4]: https://developers.raycast.com/api-reference/storage?utm_source=chatgpt.com "Storage"
[5]: https://docs.anthropic.com/en/docs/claude-code/sdk/sdk-permissions?utm_source=chatgpt.com "Handling Permissions - Claude Docs - Anthropic"
[6]: https://developers.raycast.com/api-reference/preferences?utm_source=chatgpt.com "Preferences | Raycast API"
[7]: https://github.com/anthropics/claude-code/issues/7279?utm_source=chatgpt.com "[BUG] In-process MCP servers bug in Claude Code ..."
[8]: https://developers.raycast.com/basics/prepare-an-extension-for-store?utm_source=chatgpt.com "Prepare an Extension for Store"
[9]: https://docs.claude.com/en/docs/claude-code/settings?utm_source=chatgpt.com "Claude Code settings"
[10]: https://github.com/anthropics/claude-code/issues/6699?utm_source=chatgpt.com "Critical Security Bug: deny permissions in settings.json are ..."
[11]: https://github.com/modelcontextprotocol/modelcontextprotocol?utm_source=chatgpt.com "Specification and documentation for the Model Context ..."