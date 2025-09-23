

# PRD: Claude Code for Raycast with MCP Quick Install and Permission Controls

## Problem to solve

You want a native Raycast chat that gives you the full Claude Code experience, including tool execution, planning mode, persistent sessions, clean in-UI authentication for Claude Max, and fast toggles for strict or permissive security. You also want a convenient MCP Quick Install flow that makes common servers one click, similar to Cursor’s “Enable providers.” The extension should respect Claude Code’s permission model, including a “skip all permissions” mode for speed, with clear state and persistence across sessions. ([Claude Docs][1])

## Goals

1. Summon a streaming chat command that talks to Claude Code via the TypeScript SDK `query()` with token-level partials, permission prompts, and tool results in a compact Raycast UI. ([Claude Docs][1])
2. Authenticate cleanly with a Claude Max account by invoking the SDK’s login flow. Provide an API key fallback stored securely through Raycast Preferences. Keep secrets out of plaintext. ([Claude Docs][1])
3. Ship a first-class Permissions command that exposes the SDK’s `PermissionMode` values and writes optional rule files for allow, deny, and ask. Persist the selected mode so it is always respected by the chat command. ([Claude Docs][1])
4. Ship MCP Quick Install that lets users choose curated servers and install either at user scope via runtime `options.mcpServers` or at project scope by writing a `.mcp.json`. Provide guardrails for secrets. ([Claude Docs][1])
5. Provide session continuity by persisting `session_id` per working directory, with resume and compact options. ([Claude Docs][1])

## Non-goals

* Recreating the full Claude desktop UI or CLI. Keep the Raycast experience fast and focused.
* Building custom OAuth flows for third-party MCP servers. When a server needs authorization, the UX will direct users to complete auth through Claude Code’s standard paths after install. ([Claude Docs][2])

## Primary users

* People who want a fully capable agent on hand to do any tasks with their computer
* PMs and designers on Claude Max who want quick answers, code explanation, and safe plan-only sessions.

## Key user stories

* As a Max user, I select “Claude.ai login” in the extension and run `/login` or `/status` to confirm the session. The SDK handles browser handoff and Keychain storage, so I never paste tokens. ([Claude Docs][1])
* As a power user, I set Permission Mode to “bypassPermissions,” and the chat respects it every time without extra prompts. I can drop back to “plan” when I need safety. ([Claude Docs][1])
* As a builder, I click “MCP Quick Install,” choose Filesystem and Search servers, and select Project scope. The command writes `.mcp.json` to my repo and tells me to run `/mcp` to complete any required authorization. ([Claude Docs][2])

## UX outline

* **Command: Claude Code Chat**. List view with a message input in Raycast’s search bar. Messages stream into a scrolling list. Permission prompts appear as Alerts with “Allow” and “Deny.” Status and errors use Toasts. ([Raycast API][3])
* **Command: MCP Quick Install**. Form with curated servers and a scope selector. For user scope, selections are saved into LocalStorage and injected at runtime. For project scope, a `.mcp.json` is written. ([Raycast API][4])
* **Command: Permissions**. Form with a Permission Mode dropdown and an optional rules editor that writes settings files to user or project scope. ([Claude Docs][5])
* **Preferences**. Authentication method, Anthropic API key (password field), default model alias, default permission mode, and a toggle to enable user-scope MCP servers. ([Raycast API][6])



## Risks and constraints

* Claude Code permission rules are file-based and interact with runtime `canUseTool`. Rules are processed first, then your callback. There have been recent community reports of deny rules not applying in some versions. Provide a clear troubleshooting note and let users fall back to “plan” or “bypassPermissions” while the vendor resolves issues. ([Claude Docs][5])
* In-process MCP servers have had regressions reported in the wild. Prefer stdio or SSE servers for stability and document a fallback. ([GitHub][7])
* Raycast Store review requires clear setup docs and a privacy note for token storage. Follow their Store checklist. ([Raycast API][8])

---

# System architecture

* **UI**. Raycast extension using React and `@raycast/api`. Use List for chat, Form for setup commands, Toasts, Alerts, and LocalStorage. ([Raycast API][4])
* **Claude Code integration**. `query()` from the TypeScript SDK with `includePartialMessages` set to true for streaming. Respect `permissionMode`, supply `canUseTool`, and pass `mcpServers` when user-scope MCPs are enabled. `setPermissionMode` at runtime allows live switching during a stream if needed. ([Claude Docs][1])
* **Auth**. Preferred path is Claude.ai login triggered through a slash command. API key fallback lives in Raycast Preferences of type password. ([Claude Docs][1])
* **MCP**. Support two scopes. Project scope writes `.mcp.json`. User scope persists JSON in LocalStorage and injects it into `options.mcpServers` for every `query()` call. Claude Code supports stdio, SSE, and in-process entries. ([Claude Docs][1])
* **State**. Persist `session_id` and last used directory in LocalStorage. Use `resume` to continue a session. ([Claude Docs][1])

---

# Data and config formats

## `.mcp.json` for project scope

```json
{
  "mcpServers": {
    "filesystem": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem"],
      "env": { "ALLOWED_PATHS": "/Users/alex/src,/Users/alex/Documents" }
    },
    "braveSearch": {
      "type": "sse",
      "url": "https://api.search.brave.com/mcp/sse",
      "headers": { "X-API-KEY": "${BRAVE_API_KEY}" }
    }
  }
}
```

Claude Code supports stdio and SSE servers with the fields above. Variables in headers are acceptable placeholders that the user can later supply via environment. ([Claude Docs][2])

## `settings.json` and `settings.local.json`

```json
{
  "permissions": {
    "allow": ["Bash(git status)", "Read(./README.md)"],
    "deny": ["Read(./.env)", "Write(./production/**)"],
    "ask": ["Bash(npm run deploy:*)", "WebFetch"]
  }
}
```

User scope lives at `~/.claude/settings.json`. Project scope lives at `.claude/settings.local.json`. The rules are evaluated by Claude Code before your runtime callback. Acknowledge that recent versions have had reports of deny rules being ignored. Provide a fallback plan in the UI. ([Claude Docs][9])

---

# Manifest and preferences

Use a single extension with three commands and shared preferences.

```json
{
  "raycast": {
    "schemaVersion": 1,
    "title": "Claude Code",
    "icon": "icon.png",
    "author": "you",
    "categories": ["Developer Tools"],
    "platforms": ["macOS"],
    "engines": { "node": ">=18" },
    "commands": [
      { "name": "chat", "title": "Claude Code Chat", "mode": "view" },
      { "name": "mcp-quick-install", "title": "MCP Quick Install", "mode": "view" },
      { "name": "permissions", "title": "Claude Code Permissions", "mode": "view" }
    ],
    "preferences": [
      {
        "name": "authMethod",
        "title": "Authentication Method",
        "type": "dropdown",
        "data": [
          { "title": "Claude.ai (Max or Pro)", "value": "claudeai" },
          { "title": "Anthropic API Key", "value": "api-key" }
        ],
        "default": "claudeai",
        "required": true
      },
      {
        "name": "anthropicApiKey",
        "title": "Anthropic API Key",
        "type": "password",
        "description": "Only used when method is API key"
      },
      {
        "name": "defaultModel",
        "title": "Default Model",
        "type": "dropdown",
        "data": [
          { "title": "Default", "value": "default" },
          { "title": "Sonnet", "value": "sonnet" },
          { "title": "Opus", "value": "opus" },
          { "title": "Opus plan", "value": "opusplan" }
        ],
        "default": "opusplan"
      },
      {
        "name": "permissionMode",
        "title": "Permission Mode",
        "type": "dropdown",
        "data": [
          { "title": "Default", "value": "default" },
          { "title": "Plan only", "value": "plan" },
          { "title": "Accept edits", "value": "acceptEdits" },
          { "title": "Skip all permissions", "value": "bypassPermissions" }
        ],
        "default": "plan",
        "required": true
      },
      {
        "name": "useUserMcpServers",
        "title": "Enable user-scope MCP servers",
        "type": "checkbox",
        "default": true
      }
    ]
  }
}
```

Preferences API, Storage API, and Store guidelines are stable and documented. ([Raycast API][6])

---

# Command implementations

## Chat command

Key responsibilities

* Read Preferences and LocalStorage.
* On first render, send `/status` to nudge login if authMethod is “claudeai.”
* On send, call `query()` with `includePartialMessages`, `permissionMode`, and `mcpServers` if enabled.
* Implement `canUseTool` to show an Alert and return the appropriate `PermissionResult`.
* If the user flips permission mode during a stream, use `setPermissionMode` on the `Query` object. ([Claude Docs][1])

Skeleton

```tsx
import {
  Action, ActionPanel, List, confirmAlert, Alert, showToast, Toast, LocalStorage, environment
} from "@raycast/api";
import { useEffect, useState, useRef } from "react";
import {
  query, type SDKMessage, type SDKSystemMessage, type SDKPartialAssistantMessage, type PermissionResult
} from "@anthropic-ai/claude-code";

type Prefs = {
  authMethod: "claudeai" | "api-key";
  anthropicApiKey?: string;
  defaultModel: string;
  permissionMode: "default" | "plan" | "acceptEdits" | "bypassPermissions";
  useUserMcpServers?: boolean;
};

export default function Chat() {
  const prefs = environment.preferences as Prefs;
  const [searchText, setSearchText] = useState("");
  const [isLoading, setIsLoading] = useState(false);
  const [messages, setMessages] = useState<{ role: "user" | "assistant" | "system"; text: string; id: string }[]>([]);
  const [sessionId, setSessionId] = useState<string | undefined>(undefined);
  const streamBuffer = useRef("");

  useEffect(() => {
    // Suggest login through Claude Code’s flow
    if (prefs.authMethod === "claudeai") {
      void sendSlash("/status");
    }
  }, []);

  async function permissionPrompt(toolName: string, input: any): Promise<PermissionResult> {
    const ok = await confirmAlert({
      title: `Allow ${toolName}?`,
      message: typeof input === "string" ? input : JSON.stringify(input).slice(0, 600),
      primaryAction: { title: "Allow" },
      dismissAction: { title: "Deny" }
    });
    return ok ? { behavior: "allow", updatedInput: input } : { behavior: "deny", message: "User denied in Raycast" };
  }

  async function sendSlash(cmd: string) {
    setIsLoading(true);
    try {
      const mcpServers = await readUserScopeMcpServers(prefs);
      for await (const m of query({
        prompt: cmd,
        options: {
          includePartialMessages: true,
          permissionMode: prefs.permissionMode,
          model: prefs.defaultModel,
          mcpServers,
          env: prefs.authMethod === "api-key" && prefs.anthropicApiKey ? { ANTHROPIC_API_KEY: prefs.anthropicApiKey } : process.env
        }
      })) {
        await onMessage(m);
      }
    } catch (e) {
      await showToast({ style: Toast.Style.Failure, title: "Slash failed", message: String(e) });
    } finally {
      setIsLoading(false);
    }
  }

  async function onMessage(m: SDKMessage) {
    if (m.type === "system" && m.subtype === "init") {
      const init = m as SDKSystemMessage;
      setSessionId(init.session_id);
      await showToast({ style: Toast.Style.Success, title: `Session: ${init.model}` });
      return;
    }
    if (m.type === "stream_event") {
      const ev = m as SDKPartialAssistantMessage;
      if (ev.event?.type === "content.delta" && "delta" in ev.event && ev.event.delta?.type === "text_delta") {
        streamBuffer.current += ev.event.delta.text ?? "";
        setMessages((prev) => {
          const last = prev[prev.length - 1];
          if (last?.role === "assistant") {
            const copy = prev.slice();
            copy[prev.length - 1] = { ...last, text: streamBuffer.current };
            return copy;
          }
          return [...prev, { role: "assistant", text: streamBuffer.current, id: ev.uuid }];
        });
      }
      return;
    }
  }

  async function sendMessage() {
    const text = searchText.trim();
    if (!text) return;
    setSearchText("");
    setMessages((p) => [...p, { role: "user", text, id: crypto.randomUUID() }]);
    streamBuffer.current = "";
    setIsLoading(true);
    try {
      const mcpServers = await readUserScopeMcpServers(prefs);
      for await (const m of query({
        prompt: text,
        options: {
          includePartialMessages: true,
          resume: sessionId,
          permissionMode: prefs.permissionMode,
          model: prefs.defaultModel,
          canUseTool: permissionPrompt,
          mcpServers,
          env: prefs.authMethod === "api-key" && prefs.anthropicApiKey ? { ANTHROPIC_API_KEY: prefs.anthropicApiKey } : process.env
        }
      })) {
        await onMessage(m);
      }
    } catch (e) {
      await showToast({ style: Toast.Style.Failure, title: "Claude Code error", message: String(e) });
    } finally {
      setIsLoading(false);
    }
  }

  return (
    <List isLoading={isLoading} searchText={searchText} onSearchTextChange={setSearchText} searchBarPlaceholder="Type a message or slash command…">
      <List.Section title="Conversation">
        {messages.map((m) => (
          <List.Item key={m.id} title={m.role === "user" ? "You" : m.role === "assistant" ? "Claude" : "System"} subtitle={m.text} />
        ))}
      </List.Section>
      <List.EmptyView title="Start a conversation" description="Press Enter to send" actions={<ActionPanel><Action title="Send" onAction={sendMessage} /></ActionPanel>} />
    </List>
  );
}

async function readUserScopeMcpServers(prefs: Prefs) {
  if (!prefs.useUserMcpServers) return {};
  const raw = await LocalStorage.getItem<string>("mcpServers");
  return raw ? JSON.parse(raw) : {};
}
```

The code uses `options.permissionMode`, `options.mcpServers`, and `includePartialMessages` exactly as specified in the SDK reference. It is safe to call `/status` and `/login` as plain prompts. ([Claude Docs][1])

## MCP Quick Install command

Responsibilities

* Render a form with curated servers and a scope selector.
* On submit, write `.mcp.json` for project scope, or persist to LocalStorage for user scope.
* For SSE servers that require tokens, record placeholders. Encourage users to run `/mcp` to complete setup or auth. ([Claude Docs][2])

Skeleton

```tsx
import { Action, ActionPanel, Form, showToast, Toast, LocalStorage } from "@raycast/api";
import fs from "fs";
import path from "path";

const CATALOG = {
  filesystem: { type: "stdio" as const, command: "npx", args: ["-y", "@modelcontextprotocol/server-filesystem"], envKeys: ["ALLOWED_PATHS"] },
  braveSearch: { type: "sse" as const, url: "https://api.search.brave.com/mcp/sse", headers: { "X-API-KEY": "${BRAVE_API_KEY}" } },
  fetch: { type: "sse" as const, url: "https://mcp.example.com/fetch", headers: { Authorization: "Bearer ${API_TOKEN}" } }
};

export default function MCPQuickInstall() {
  return (
    <Form actions={<ActionPanel><Action.SubmitForm title="Install" onSubmit={onSubmit} /></ActionPanel>}>
      <Form.Checkbox id="filesystem" label="Filesystem (stdio via npx)" defaultValue />
      <Form.Checkbox id="braveSearch" label="Brave Search (SSE, requires key)" />
      <Form.Checkbox id="fetch" label="Fetch (SSE example)" />

      <Form.Dropdown id="scope" title="Scope" defaultValue="user">
        <Form.Dropdown.Item value="user" title="User (runtime in Raycast)" />
        <Form.Dropdown.Item value="project" title="Project (.mcp.json)" />
      </Form.Dropdown>

      <Form.FilePicker id="projectDir" title="Project folder" canChooseDirectories canChooseFiles={false} />

      <Form.TextField id="allowedPaths" title="Filesystem allowed paths" placeholder="/Users/alex/src,/Users/alex/Documents" />
      <Form.PasswordField id="braveKey" title="Brave API key (optional)" />
      <Form.PasswordField id="apiToken" title="Generic API token (optional)" />
    </Form>
  );
}

async function onSubmit(values: any) {
  const chosen: Record<string, any> = {};

  if (values.filesystem) {
    chosen.filesystem = {
      type: "stdio",
      command: CATALOG.filesystem.command,
      args: CATALOG.filesystem.args,
      env: { ALLOWED_PATHS: values.allowedPaths ?? "" }
    };
  }
  if (values.braveSearch) {
    chosen.braveSearch = {
      type: "sse",
      url: CATALOG.braveSearch.url,
      headers: { "X-API-KEY": values.braveKey ?? "${BRAVE_API_KEY}" }
    };
  }
  if (values.fetch) {
    chosen.fetch = {
      type: "sse",
      url: CATALOG.fetch.url,
      headers: { Authorization: `Bearer ${values.apiToken ?? "${API_TOKEN}"}` }
    };
  }

  if (values.scope === "user") {
    await LocalStorage.setItem("mcpServers", JSON.stringify(chosen));
    await showToast({ style: Toast.Style.Success, title: "MCP ready for user scope" });
    return;
  }

  const dir = values.projectDir?.[0];
  if (!dir) {
    await showToast({ style: Toast.Style.Failure, title: "Pick a project folder" });
    return;
  }
  const file = path.join(dir, ".mcp.json");
  fs.writeFileSync(file, JSON.stringify({ mcpServers: chosen }, null, 2), "utf-8");
  await showToast({ style: Toast.Style.Success, title: "Wrote .mcp.json", message: file });
}
```

The structure matches the SDK MCP guide and supports stdio and SSE servers. ([Claude Docs][2])

## Permissions command

Responsibilities

* Change global Permission Mode through Preferences, which your chat command reads on each `query()` call.
* Optionally write allow, deny, and ask lists to `~/.claude/settings.json` or `.claude/settings.local.json`. Document that project scope is often the safer place to test rules. Point users to plan mode if they encounter version defects. ([Claude Docs][5])

Skeleton

```tsx
import { Action, ActionPanel, Form, showToast, Toast } from "@raycast/api";
import fs from "fs";
import path from "path";
import os from "os";

export default function Permissions() {
  return (
    <Form actions={<ActionPanel><Action.SubmitForm title="Save" onSubmit={onSubmit} /></ActionPanel>}>
      <Form.Description title="Global mode" text="Change the Permission Mode in Preferences. This UI writes rules only." />
      <Form.TextArea id="allow" title="Allow rules" placeholder={'Bash(git status)\nRead(./README.md)'} />
      <Form.TextArea id="deny" title="Deny rules" placeholder={'Read(./.env)\nWrite(./production/**)'} />
      <Form.TextArea id="ask" title="Ask rules" placeholder={'Bash(npm run deploy:*)\nWebFetch'} />

      <Form.Dropdown id="rulesScope" title="Write rules to" defaultValue="user">
        <Form.Dropdown.Item value="user" title="User: ~/.claude/settings.json" />
        <Form.Dropdown.Item value="project" title="Project: .claude/settings.local.json (choose folder below)" />
      </Form.Dropdown>
      <Form.FilePicker id="projectDir" title="Project folder" canChooseDirectories canChooseFiles={false} />
    </Form>
  );
}

function split(s?: string) {
  return s ? s.split("\n").map((x) => x.trim()).filter(Boolean) : [];
}

async function onSubmit(values: any) {
  const rules = { permissions: { allow: split(values.allow), deny: split(values.deny), ask: split(values.ask) } };

  let file = path.join(os.homedir(), ".claude", "settings.json");
  if (values.rulesScope === "project") {
    const dir = values.projectDir?.[0];
    if (!dir) { await showToast({ style: Toast.Style.Failure, title: "Pick a project folder" }); return; }
    const claudeDir = path.join(dir, ".claude");
    fs.mkdirSync(claudeDir, { recursive: true });
    file = path.join(claudeDir, "settings.local.json");
  }

  fs.mkdirSync(path.dirname(file), { recursive: true });
  fs.writeFileSync(file, JSON.stringify(rules, null, 2), "utf-8");
  await showToast({ style: Toast.Style.Success, title: "Saved rules", message: file });
}
```

Rules structure and file locations follow the settings documentation. Surface a troubleshooting note in the UI for deny rules if users report issues on specific versions. ([Claude Docs][9])

---

# Authentication flows

* **Claude.ai login for Max**. The chat command can issue `/status` or `/login`. The SDK launches the browser and stores credentials securely. Keep this as the default. ([Claude Docs][1])
* **API key fallback**. Add `ANTHROPIC_API_KEY` in Preferences. Provide it to `query()` via `options.env`. Raycast Preferences use a password field for secrecy. ([Claude Docs][1])

---

# Permissions and safety model

* The SDK exposes `PermissionMode` with four values: `default`, `acceptEdits`, `bypassPermissions`, and `plan`. Your chat must always pass the user’s selected mode. Consider a small status badge in the chat indicating the active mode. `Query.setPermissionMode` can adjust during a stream. ([Claude Docs][1])
* Layered control is best. Use file-based rules for stable policy and your `canUseTool` callback for real-time prompts or overrides. If users report deny rules not working, steer them to plan mode or to strict prompts until they update. ([Claude Docs][5])
* Never enable “skip all permissions” by default. Make it obvious and persistent when enabled. ([Claude Docs][1])

---

# Testing plan

1. **Unit tests**.

   * Validate serialization for `.mcp.json` and settings files.
   * Validate LocalStorage read and write for `mcpServers`.
2. **Integration tests**.

   * Use a mock stdio server process to ensure Raycast can stream tool results and that `canUseTool` gates execution.
   * Simulate permission modes and check tool calls are allowed, asked, or blocked as intended. ([Claude Docs][1])
3. **Manual checks**.

   * Test Max login on a clean machine.
   * Test SSE server that needs a header to confirm that placeholders are not executed without a token.
   * Test `.claude/settings.local.json` deny rules in a throwaway repo. Capture any version anomalies with a link to the issue. ([GitHub][10])

---

# Deployment checklist

* Include a README with setup for Claude.ai login, API key fallback, and the MCP Quick Install workflow.
* Include privacy notes regarding token storage and LocalStorage use.
* Provide two screenshots for Store submission, one for chat and one for MCP Quick Install.
* Follow Store review guidance on naming, icons, and onboarding text. ([Raycast API][8])

---

# Strong practical defaults

* Default model alias to `opusplan` for planning and Sonnet for execution. Users can switch with a slash command or preference toggle. The SDK allows free model strings; keep aliases consistent with your organization. ([Claude Docs][1])
* Default Permission Mode to `plan`. The toggle to “Skip all permissions” is visible and sticky.
* Keep the MCP catalog small and high quality. Filesystem and a single search server are enough to start. You can add a “More servers” link in the form description that points to a curated list or the MCP repo. ([GitHub][11])

---

# Known caveats and mitigations

* **Deny rules may fail on some versions**. Provide a “Safe mode” button that flips to plan mode automatically when the user reports unexpected behavior. Link to a Troubleshooting section in README with known version ranges. ([GitHub][10])
* **In-process MCP** can be flaky. Prefer stdio and SSE in the Quick Install catalog. If users insist on in-process, wrap it behind an “Advanced” disclosure and mention the open issue. ([GitHub][7])

---

# References

* Claude Code TypeScript SDK reference: `query`, `Options`, `PermissionMode`, `mcpServers`, message types, streaming, and `setPermissionMode`. ([Claude Docs][1])
* SDK guide for permissions: `canUseTool` and rules design. ([Claude Docs][5])
* SDK guide for MCP: stdio and SSE configurations and examples. ([Claude Docs][2])
* MCP spec and official docs. ([GitHub][11])
* Raycast Storage, Preferences, and Store review docs. ([Raycast API][4])
* Community reports on permission rules and in-process MCP stability. Treat as situational but informative during testing. ([GitHub][10])

---

If you want me to turn this into a ready-to-publish repo layout with the three commands, a polished README, a troubleshooting section, and Store screenshots copy, I can produce that in one pass.

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
