# Quick Reference Guide

## Claude Code SDK

### Essential Functions

```typescript
// Main query function
import { query } from "@anthropic-ai/claude-code";

for await (const message of query({
  prompt: "Your request",
  options: { /* config */ }
})) {
  // Handle messages
}

// Create MCP tool
import { tool } from "@anthropic-ai/claude-code";
const customTool = tool({ name, description, inputSchema, handler });

// Create MCP server
import { createSdkMcpServer } from "@anthropic-ai/claude-code";
const server = createSdkMcpServer({ name, version, tools });
```

### Key Options

```typescript
interface Options {
  model?: string;                     // Model selection
  permissionMode?: PermissionMode;    // "default" | "acceptEdits" | "bypassPermissions"
  canUseTool?: CanUseToolCallback;    // Custom permission handler
  mcpServers?: Record<string, any>;   // MCP server config
  resume?: string;                     // Session ID to resume
  includePartialMessages?: boolean;   // Stream partial content
  maxTokens?: number;                  // Token limit
  env?: Record<string, string>;       // Environment variables
}
```

### Message Types

```typescript
type SDKMessage =
  | SDKAssistantMessage    // Complete assistant response
  | SDKUserMessage         // User input
  | SDKResultMessage       // Execution result
  | SDKSystemMessage       // System info
  | SDKPartialAssistantMessage; // Streaming content
```

### Permission Result

```typescript
interface PermissionResult {
  behavior: "allow" | "deny";
  message?: string;
  updatedInput?: any;
}
```

## Raycast API

### Essential Imports

```typescript
import {
  // Components
  List, Form, Detail, Grid,

  // Actions
  ActionPanel, Action,

  // Storage
  LocalStorage, Cache,

  // Preferences
  getPreferenceValues,

  // UI Feedback
  showToast, Toast, showHUD,
  confirmAlert, Alert,

  // Navigation
  pushToPage, popToRoot,

  // Environment
  environment,

  // Icons
  Icon, Color
} from "@raycast/api";
```

### Common Components

```typescript
// List with search
<List
  searchText={text}
  onSearchTextChange={setText}
  isLoading={loading}
>
  <List.Item
    title="Title"
    subtitle="Subtitle"
    icon={Icon.Star}
    actions={<ActionPanel>...</ActionPanel>}
  />
</List>

// Form with fields
<Form actions={<ActionPanel>...</ActionPanel>}>
  <Form.TextField id="name" title="Name" />
  <Form.TextArea id="desc" title="Description" />
  <Form.Dropdown id="type" title="Type">
    <Form.Dropdown.Item value="a" title="Option A" />
  </Form.Dropdown>
</Form>

// Detail with markdown
<Detail
  markdown={content}
  metadata={<Detail.Metadata>...</Detail.Metadata>}
/>
```

### Storage Operations

```typescript
// LocalStorage (persistent)
await LocalStorage.setItem("key", "value");
const value = await LocalStorage.getItem<string>("key");
await LocalStorage.removeItem("key");

// Cache (temporary)
const cache = new Cache();
cache.set("key", "value", { ttl: 1000 * 60 });
const cached = cache.get("key");
```

### Preferences

```typescript
interface Preferences {
  apiKey: string;
  model: string;
}

const prefs = getPreferenceValues<Preferences>();
```

## Integration Patterns

### Basic Assistant Setup

```typescript
import { query } from "@anthropic-ai/claude-code";
import { List, showToast, Toast } from "@raycast/api";

export default function Assistant() {
  const [messages, setMessages] = useState<Message[]>([]);

  async function sendMessage(text: string) {
    try {
      for await (const msg of query({ prompt: text })) {
        handleMessage(msg);
      }
    } catch (error) {
      await showToast({
        style: Toast.Style.Failure,
        title: "Error",
        message: String(error)
      });
    }
  }

  return <List>...</List>;
}
```

### Permission Handler

```typescript
async function permissionHandler(
  toolName: string,
  input: any
): Promise<PermissionResult> {
  // Always allow reads
  if (toolName === "Read") {
    return { behavior: "allow", updatedInput: input };
  }

  // Ask for dangerous operations
  if (isDangerous(toolName, input)) {
    const confirmed = await confirmAlert({
      title: `Allow ${toolName}?`,
      message: "This is a dangerous operation"
    });

    return confirmed
      ? { behavior: "allow", updatedInput: input }
      : { behavior: "deny", message: "User denied" };
  }

  return { behavior: "allow", updatedInput: input };
}
```

### MCP Auto-Configuration

```typescript
async function getAutoMCP() {
  const servers: Record<string, any> = {};

  // Filesystem server
  servers.filesystem = {
    command: "npx",
    args: ["-y", "@modelcontextprotocol/server-filesystem"],
    env: { ALLOWED_PATHS: process.cwd() }
  };

  // SSE server
  if (process.env.API_KEY) {
    servers.api = {
      type: "sse",
      url: "https://api.example.com/mcp",
      headers: { "X-API-KEY": process.env.API_KEY }
    };
  }

  return servers;
}
```

### Session Management

```typescript
// Save session
await LocalStorage.setItem(
  `session_${cwd}`,
  JSON.stringify({ sessionId, messages, trustLevel })
);

// Load session
const stored = await LocalStorage.getItem<string>(`session_${cwd}`);
const session = stored ? JSON.parse(stored) : null;

// Resume session
for await (const msg of query({
  prompt: text,
  options: { resume: session?.sessionId }
})) {
  // Continue conversation
}
```

## Common Tool Inputs

### File Operations

```typescript
// Read
{ file_path: string, offset?: number, limit?: number }

// Write
{ file_path: string, content: string }

// Edit
{ file_path: string, old_string: string, new_string: string, replace_all?: boolean }

// MultiEdit
{ file_path: string, edits: Array<{ old_string, new_string, replace_all? }> }
```

### Shell Operations

```typescript
// Bash
{ command: string, timeout?: number, run_in_background?: boolean }

// BashOutput
{ bash_id: string, filter?: string }

// KillShell
{ shell_id: string }
```

### Search Operations

```typescript
// Grep
{
  pattern: string,
  path?: string,
  glob?: string,
  type?: string,
  output_mode?: "content" | "files_with_matches" | "count",
  "-i"?: boolean,  // case insensitive
  "-n"?: boolean,  // show line numbers
  "-A"?: number,   // lines after
  "-B"?: number,   // lines before
  "-C"?: number    // lines context
}

// Glob
{ pattern: string, path?: string }

// WebSearch
{ query: string, allowed_domains?: string[], blocked_domains?: string[] }
```

## Keyboard Shortcuts

```typescript
// Common shortcuts
const shortcuts = {
  send: { modifiers: ["cmd"], key: "return" },
  cancel: { modifiers: ["escape"], key: "" },
  copy: { modifiers: ["cmd"], key: "c" },
  refresh: { modifiers: ["cmd"], key: "r" },
  delete: { modifiers: ["cmd"], key: "delete" },
  selectAll: { modifiers: ["cmd"], key: "a" }
};

// Usage
<Action
  title="Send"
  onAction={handleSend}
  shortcut={shortcuts.send}
/>
```

## Error Codes

```typescript
// Common error codes to handle
const ERROR_CODES = {
  AUTH_REQUIRED: "Authentication required",
  RATE_LIMIT: "Rate limited",
  PERMISSION_DENIED: "Permission denied",
  NETWORK_ERROR: "Network error",
  TIMEOUT: "Request timeout",
  INVALID_INPUT: "Invalid input",
  NOT_FOUND: "Resource not found"
};
```

## Useful Hooks

```typescript
import { usePromise, useCachedPromise, useForm } from "@raycast/utils";

// Async data fetching
const { isLoading, data, error } = usePromise(fetchData);

// Cached async data
const { data } = useCachedPromise(fetchData, [], {
  cacheKey: "my-data",
  ttl: 1000 * 60 * 5
});

// Form management
const { handleSubmit, itemProps } = useForm<FormData>({
  onSubmit: async (values) => { /* submit */ }
});
```

## Permission Rules Format

```json
{
  "permissions": {
    "allow": [
      "Read(**/*.md)",           // Read any markdown
      "Bash(npm run test)"       // Specific command
    ],
    "deny": [
      "Read(./.env)",            // Block env files
      "Bash(rm -rf *)"           // Block dangerous
    ],
    "ask": [
      "Write(**)",               // Ask for all writes
      "Bash(git push*)"          // Ask for pushes
    ]
  }
}
```

## Trust Levels

```typescript
enum TrustLevel {
  Untrusted = 0,    // Read-only
  Minimal = 1,      // + Safe bash
  Moderate = 3,     // + Edit
  High = 5,         // + Write
  Full = 10         // Everything auto-approved
}
```

## Package.json Template

```json
{
  "name": "ai-assistant",
  "title": "AI Assistant",
  "commands": [{
    "name": "assistant",
    "title": "AI Assistant",
    "mode": "view"
  }],
  "preferences": [{
    "name": "apiKey",
    "title": "API Key",
    "type": "password",
    "required": false
  }],
  "dependencies": {
    "@raycast/api": "^1.83.2",
    "@anthropic-ai/claude-code": "^1.0.0"
  },
  "scripts": {
    "dev": "ray develop",
    "build": "ray build",
    "lint": "ray lint"
  }
}
```

## Debug Utilities

```typescript
// Debug logging
const debug = (...args: any[]) => {
  if (environment.isDevelopment) {
    console.log("[DEBUG]", ...args);
  }
};

// Performance timing
const timer = {
  start: Date.now(),
  log: (label: string) => {
    debug(`${label}: ${Date.now() - timer.start}ms`);
  }
};

// Error reporting
const reportError = async (error: Error) => {
  console.error(error);
  await showToast({
    style: Toast.Style.Failure,
    title: "Error",
    message: error.message
  });
};
```

## Cheatsheet

### Quick Commands

```bash
# Development
npm run dev          # Start development mode
npm run build        # Build for production
npm run lint         # Lint code
npm test            # Run tests

# Raycast
ray develop         # Start dev server
ray build           # Build extension
ray lint            # Lint with Raycast rules
ray publish         # Publish to store
```

### Common Patterns

```typescript
// Loading state
if (isLoading) return <List isLoading />;

// Empty state
if (!data.length) {
  return <List.EmptyView title="No results" />;
}

// Error state
if (error) {
  return <Detail markdown={`Error: ${error.message}`} />;
}

// Success feedback
await showToast({
  style: Toast.Style.Success,
  title: "Done!"
});

// Confirmation
const ok = await confirmAlert({
  title: "Are you sure?"
});
if (!ok) return;
```

### Type Guards

```typescript
// Check message type
if (message.type === "assistant") {
  // Handle assistant message
}

// Check tool safety
const isSafe = (tool: string, input: any): boolean => {
  return SAFE_TOOLS.includes(tool) ||
         (tool === "Bash" && isSafeCommand(input.command));
};

// Check environment
if (environment.isDevelopment) {
  // Development only code
}
```