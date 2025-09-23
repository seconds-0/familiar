## Claude Raycast – Code & Implementation Review (2025-09-23)

This document reviews the current repository implementation against the intent described in `CLAUDE.md`, `docs/prd.md`, `docs/01-steelthread.md`, `docs/claude-code-sdk.md`, `docs/raycast-api.md`, and `docs/integration-guide.md`. It includes recommended corrections with concrete code snippets.

### Executive overview
- **Overall**: Strong steel-thread MVP. Streaming chat, basic state persistence, and Raycast-native UI are in place.
- **Gaps/Risks**: Runtime `npx` for MCP server, non-immutable state updates during streaming, excessive LocalStorage writes, loose typing for SDK events, and reliance on `process.cwd()` for context.
- **Docs alignment**: Mostly consistent with `01-steelthread.md`. `CLAUDE.md` says MCP not implemented, but code already attempts to use filesystem MCP.

### Critical issues to fix now (correctness & stability)

- **Avoid `npx` at runtime for MCP filesystem server**
  - Runtime installs are slow and brittle; may not pass Raycast Store review.
  - Prefer bundling the server or pinning it as a dependency and invoking a deterministic binary path.
  - At minimum, fail fast with a friendly message if the server cannot be started.

- **Specify stdio type for MCP servers**
  - Your current `mcpServers` entry lacks `type: "stdio"` which is required for process-based servers.

```typescript
// mcp.ts (new)
export function getFilesystemMcpServer(allowedPath: string) {
  const filesystemServerCmd = 
    "/absolute/path/to/server-filesystem"; // Prefer bundled/pinned binary

  return {
    type: "stdio" as const,
    command: filesystemServerCmd,
    args: [],
    env: { ALLOWED_PATHS: allowedPath }
  };
}
```

- **Use immutable updates for streaming content**
  - Avoid mutating `lastMessage` in place. Replace the element with a new object to keep React state updates predictable.

```typescript
// In partial stream handling
streamBuffer.current += event.delta || "";
setMessages((prev) => {
  const updated = [...prev];
  const i = updated.length - 1;
  if (i >= 0 && updated[i].role === "assistant") {
    updated[i] = { ...updated[i], content: streamBuffer.current };
  }
  return updated;
});
```

- **Debounce LocalStorage persistence**
  - Streaming generates many state changes; debounce to ~250–500ms and on finalize.

```typescript
// session.ts (new)
import { LocalStorage } from "@raycast/api";

let saveTimer: NodeJS.Timeout | null = null;

export function saveSessionDebounced(key: string, data: unknown, delay = 300) {
  if (saveTimer) clearTimeout(saveTimer);
  saveTimer = setTimeout(() => {
    void LocalStorage.setItem(key, JSON.stringify(data));
  }, delay);
}
```

- **Pin SDK version**
  - Replace `"@anthropic-ai/claude-code": "latest"` with a known-good version and upgrade intentionally.

```json
// package.json (snippet)
"dependencies": {
  "@anthropic-ai/claude-code": "^1.2.3",
  "@raycast/api": "^1.64.0",
  "react": "^18.2.0"
}
```

- **Abortable streams**
  - Add an `AbortController` to cancel in-flight queries on unmount or when clearing the session.

```typescript
// In component scope
const abortRef = useRef<AbortController | null>(null);

async function startQuery(prompt: string) {
  abortRef.current?.abort();
  abortRef.current = new AbortController();
  const { query } = await claudeCode; // dynamic import retained
  for await (const event of query({
    prompt,
    options: { signal: abortRef.current.signal, /* ...other opts */ }
  })) {
    await handleEvent(event);
  }
}

useEffect(() => () => abortRef.current?.abort(), []);
```

### Implementation improvements (quality & scalability)

- **Strong typing for SDK events**
  - Replace `type SDKMessage = any` with types from the SDK via `import type`.

```typescript
import type {
  SDKMessage,
  SDKAssistantMessage,
  SDKPartialAssistantMessage,
  SDKResultMessage,
  SDKSystemMessage,
  PermissionResult
} from "@anthropic-ai/claude-code";
```

- **Broaden event compatibility**
  - Handle variations like `sessionId` vs `session_id`, `result.subtype === "success"`, and `"interrupted"`.

```typescript
if (event.type === "system" && event.subtype === "init") {
  const sid = (event as any).sessionId ?? (event as any).session_id;
  if (sid) setSessionData((p) => ({ ...p, sessionId: sid }));
}

if (event.type === "result") {
  if (event.subtype === "success") {
    // optional: show a subtle success signal
  } else if (event.subtype === "interrupted") {
    // surface that execution was aborted
  }
}
```

- **Deterministic working directory**
  - `process.cwd()` in Raycast may not reflect user intent. Prefer a selected path or a stored project root.

```typescript
import { getSelectedFinderItems, LocalStorage } from "@raycast/api";

async function resolveWorkingPath(): Promise<string> {
  const selected = await getSelectedFinderItems().catch(() => []);
  if (selected.length > 0) return selected[0].path;
  const stored = await LocalStorage.getItem<string>("preferred_project_root");
  if (stored) return stored;
  return process.cwd(); // final fallback
}
```

- **Observability in development**

```typescript
import { environment } from "@raycast/api";
const debug = (...args: unknown[]) => environment.isDevelopment && console.log("[AI Assistant]", ...args);

debug("Spawning MCP filesystem server...");
```

- **Defensive MCP spawn**

```typescript
try {
  const mcp = getFilesystemMcpServer(await resolveWorkingPath());
  // pass into query options
} catch (e) {
  await showToast({ style: Toast.Style.Failure, title: "MCP Failed", message: String(e) });
  // Optional: operate in degraded mode without filesystem
}
```

- **UI polish**
  - Hide the trust dropdown until it is wired to a policy.
  - Add a small footer row that shows current working directory and a quick action to change it.

### Documentation alignment & cleanup
- Update `CLAUDE.md` “Current Implementation Status”: mark filesystem MCP as implemented; clarify that write/edit/bash are pending.
- Clarify `Cmd+Cmd` behavior in `docs/prd.md`: users must assign a global hotkey to the command in Raycast; the `shortcut` preference by itself won’t set a system-wide hotkey.
- In `docs/claude-code-sdk.md` and `docs/integration-guide.md`, reflect the recommended `type: "stdio"` in MCP examples and discourage runtime `npx` installs.

### Store readiness checklist (condensed)
- No runtime dependency installs (remove `npx` at runtime).
- Clear permission prompts only when needed; avoid noisy toasts.
- Robust error handling and graceful degradation when MCP fails.
- Version-pin external dependencies; no `latest`.
- Limit disk writes via debouncing; avoid heavy logging in production.

### Action plan (recommended order)
1. Pin SDK version; wire SDK types; broaden event handling.
2. Replace runtime `npx` with a bundled/pinned filesystem server; add `type: "stdio"`.
3. Implement immutable streaming updates and debounce persistence.
4. Add AbortController cancellation and MCP spawn failure handling.
5. Replace `process.cwd()` with a deterministic working path strategy.
6. Remove or wire the trust dropdown; add “current path” hint and action.
7. Update docs to reflect actual behavior and store-friendly practices.

### Appendix – Minimal code diffs (illustrative snippets)

- MCP server config with stdio and deterministic binary
```typescript
export function getMcpServers(allowedPath: string) {
  return {
    filesystem: {
      type: "stdio" as const,
      command: "/absolute/path/to/server-filesystem",
      args: [],
      env: { ALLOWED_PATHS: allowedPath }
    }
  };
}
```

- Immutable streaming update
```typescript
streamBuffer.current += delta;
setMessages((prev) => {
  const updated = [...prev];
  const i = updated.length - 1;
  if (i >= 0 && updated[i].role === "assistant") {
    updated[i] = { ...updated[i], content: streamBuffer.current };
  }
  return updated;
});
```

- Debounced session persistence
```typescript
useEffect(() => {
  const key = `session_${workingDir}`;
  saveSessionDebounced(key, { ...sessionData, messages });
}, [messages, sessionData, workingDir]);
```

- Abortable query flow
```typescript
abortRef.current?.abort();
abortRef.current = new AbortController();
for await (const event of query({ prompt: text, options: { signal: abortRef.current.signal, /* ... */ } })) {
  await handleEvent(event);
}
```

- Type imports for SDK
```typescript
import type { SDKMessage, SDKSystemMessage, SDKPartialAssistantMessage, SDKAssistantMessage, SDKResultMessage, PermissionResult } from "@anthropic-ai/claude-code";
```

- Version pin
```json
"@anthropic-ai/claude-code": "^1.2.3"
```

---

This review focuses on correctness, resilience, and store readiness while keeping the steel-thread scope intact. Adopting the changes above will reduce runtime flakiness, improve UX during streaming, and align the implementation with the documented architecture and best practices.
