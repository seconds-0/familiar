# Claude Agent SDK Documentation

> **Note**: This SDK was renamed from "Claude Code SDK" to "Claude Agent SDK" to reflect its broader capabilities for building AI agents beyond coding tasks. See the [Migration Guide](#migration-from-claude-code-sdk) below if you're upgrading from the old package.

## Overview

The Claude Agent SDK provides a powerful interface for building AI-powered agents and tools. It enables streaming interactions with Claude, tool usage control, and integration with Model Context Protocol (MCP) servers. Built on the same infrastructure that powers Claude Code, this SDK can be used to create agents for coding, business operations, customer support, research, and more.

## Installation

```bash
npm install @anthropic-ai/claude-agent-sdk
```

### Upgrading from Claude Code SDK

If you're migrating from the old package:

```bash
npm uninstall @anthropic-ai/claude-code
npm install @anthropic-ai/claude-agent-sdk
```

## Core API

### query() Function

The primary function for interacting with Claude Code. Creates an async generator that streams messages as they arrive.

```typescript
import { query } from "@anthropic-ai/claude-agent-sdk";

async function main() {
  for await (const message of query({
    prompt: "Help me understand this codebase",
    options: {
      model: "claude-sonnet-4-5-20250929",
      includePartialMessages: true,
      mcpServers: {},
      permissionMode: "default",
    },
  })) {
    if (message.type === "assistant") {
      console.log(message.content);
    }
  }
}
```

### Options Interface

```typescript
interface Options {
  // Model selection
  model?: string;

  // Permission control
  permissionMode?: "default" | "acceptEdits" | "bypassPermissions" | "plan";
  canUseTool?: (toolName: string, input: any) => Promise<PermissionResult>;

  // MCP configuration
  mcpServers?: Record<string, MCPServerConfig>;
  mcpConfig?: string; // Path to MCP config file

  // Session management
  resume?: string; // Resume from session ID

  // Message streaming
  includePartialMessages?: boolean;

  // Token limits
  maxTokens?: number;
  maxTurns?: number;

  // Hooks
  hooks?: {
    preToolUse?: (tool: string, input: any) => void;
    postToolUse?: (tool: string, output: any) => void;
  };

  // Tool filtering
  allowedTools?: string[];

  // Environment
  env?: Record<string, string>;
}
```

## Permission System

### Permission Modes

- **`default`**: Standard permission checks with user prompts
- **`acceptEdits`**: Automatically approve file edits
- **`bypassPermissions`**: Skip all permission checks (dangerous)
- **`plan`**: Read-only mode for planning (not currently supported)

### canUseTool Callback

Implement custom permission logic:

```typescript
const result = await query({
  prompt: "Fix the build errors",
  options: {
    canUseTool: async (toolName: string, input: any) => {
      // Custom permission logic
      if (toolName === "Bash" && input.command.includes("rm -rf")) {
        return {
          behavior: "deny",
          message: "Dangerous command blocked",
        };
      }

      // Prompt user for confirmation
      const approved = await getUserConfirmation(toolName, input);

      return approved
        ? { behavior: "allow", updatedInput: input }
        : { behavior: "deny", message: "User denied permission" };
    },
  },
});
```

### PermissionResult Interface

```typescript
interface PermissionResult {
  behavior: "allow" | "deny";
  message?: string;
  updatedInput?: any; // Optionally modify the tool input
}
```

### Permission Rules (settings.json)

Configure static permission policies:

```json
{
  "permissions": {
    "allow": ["Read(**/*.md)", "Bash(npm run lint)", "Bash(git status)"],
    "deny": ["Read(./.env)", "Write(./production/**)", "Bash(rm -rf *)"],
    "ask": ["Bash(git push*)", "WebFetch", "Edit(**/*.ts)"]
  }
}
```

#### Rule Syntax

- **Tool-specific**: `"ToolName(pattern)"`
- **Wildcards**: `**` for any depth, `*` for single level
- **Exact match**: `"Bash(npm test)"`
- **Pattern match**: `"Read(**/*.json)"`

#### Permission Evaluation Order

1. Pre-hook
2. Ask rules → prompt user
3. Deny rules → block
4. Permission mode check
5. Allow rules → approve
6. canUseTool callback
7. Post-hook

## MCP (Model Context Protocol) Servers

### stdio Server Configuration

For local process-based servers:

```typescript
const mcpServers = {
  filesystem: {
    command: "npx",
    args: ["-y", "@modelcontextprotocol/server-filesystem"],
    env: {
      ALLOWED_PATHS: "/Users/me/projects",
    },
  },
  github: {
    command: "python",
    args: ["-m", "mcp_server_github"],
    env: {
      GITHUB_TOKEN: process.env.GITHUB_TOKEN,
    },
  },
};
```

### SSE Server Configuration

For server-sent events endpoints:

```typescript
const mcpServers = {
  braveSearch: {
    type: "sse",
    url: "https://api.search.brave.com/mcp/sse",
    headers: {
      "X-API-KEY": process.env.BRAVE_API_KEY,
    },
  },
};
```

### HTTP Server Configuration

For REST API endpoints:

```typescript
const mcpServers = {
  customApi: {
    type: "http",
    url: "https://api.example.com/mcp",
    headers: {
      Authorization: `Bearer ${process.env.API_TOKEN}`,
    },
  },
};
```

### In-Process MCP Server

Create an MCP server within your application:

```typescript
import { createSdkMcpServer, tool } from "@anthropic-ai/claude-agent-sdk";

const mcpServer = createSdkMcpServer({
  name: "custom-tools",
  version: "1.0.0",
  tools: [
    tool({
      name: "deploy",
      description: "Deploy the application",
      inputSchema: z.object({
        environment: z.enum(["staging", "production"]),
      }),
      handler: async ({ environment }) => {
        // Deployment logic
        return { success: true, url: `https://${environment}.example.com` };
      },
    }),
  ],
});

// Use in query
const result = await query({
  prompt: "Deploy to staging",
  options: {
    mcpServers: {
      custom: mcpServer,
    },
  },
});
```

## Message Types

### SDKMessage Union Type

All possible message types:

```typescript
type SDKMessage =
  | SDKAssistantMessage
  | SDKUserMessage
  | SDKResultMessage
  | SDKSystemMessage
  | SDKPartialAssistantMessage;
```

### SDKAssistantMessage

```typescript
interface SDKAssistantMessage {
  type: "assistant";
  content: string;
  toolUses?: Array<{
    toolName: string;
    input: any;
    output?: any;
  }>;
}
```

### SDKUserMessage

```typescript
interface SDKUserMessage {
  type: "user";
  content: string;
  attachments?: Array<{
    type: "file" | "image";
    path?: string;
    data?: Buffer;
  }>;
}
```

### SDKResultMessage

```typescript
interface SDKResultMessage {
  type: "result";
  subtype: "success" | "error" | "interrupted";
  result?: string;
  error?: string;
  sessionId?: string;
}
```

### SDKSystemMessage

```typescript
interface SDKSystemMessage {
  type: "system";
  subtype: "init";
  version: string;
  sessionId: string;
  workingDirectory: string;
  model: string;
}
```

### SDKPartialAssistantMessage

For streaming partial content:

```typescript
interface SDKPartialAssistantMessage {
  type: "partial-assistant";
  content: string;
  delta?: string; // New content since last update
}
```

## Streaming and Events

### Handling Streaming Messages

```typescript
for await (const message of query({ prompt: "..." })) {
  switch (message.type) {
    case "system":
      if (message.subtype === "init") {
        console.log(`Session: ${message.sessionId}`);
      }
      break;

    case "partial-assistant":
      // Handle streaming text
      process.stdout.write(message.delta || "");
      break;

    case "assistant":
      // Complete message received
      console.log("\n" + message.content);
      break;

    case "result":
      if (message.subtype === "success") {
        console.log("Completed successfully");
      } else if (message.subtype === "error") {
        console.error("Error:", message.error);
      }
      break;
  }
}
```

### Interrupting Execution

```typescript
const controller = new AbortController();

// Start query with abort signal
const queryPromise = query({
  prompt: "Long running task",
  options: {
    signal: controller.signal,
  },
});

// Interrupt after timeout
setTimeout(() => controller.abort(), 5000);
```

## Tool System

### Built-in Tools

Claude Code includes several built-in tools:

- **File Operations**: Read, Write, Edit, MultiEdit
- **Shell**: Bash, BashOutput, KillShell
- **Search**: Grep, Glob, WebSearch
- **Web**: WebFetch
- **Development**: Task, TodoWrite
- **Notebooks**: NotebookEdit

### Tool Input Types

```typescript
interface EditInput {
  file_path: string;
  old_string: string;
  new_string: string;
  replace_all?: boolean;
}

interface BashInput {
  command: string;
  timeout?: number;
  run_in_background?: boolean;
}

interface GrepInput {
  pattern: string;
  path?: string;
  glob?: string;
  type?: string;
  output_mode?: "content" | "files_with_matches" | "count";
}
```

### Creating Custom Tools

```typescript
import { tool } from "@anthropic-ai/claude-agent-sdk";
import { z } from "zod";

const customTool = tool({
  name: "database-query",
  description: "Execute a database query",
  inputSchema: z.object({
    query: z.string(),
    database: z.enum(["users", "products", "orders"]),
  }),
  handler: async ({ query, database }) => {
    // Execute query
    const results = await db[database].query(query);
    return {
      rowCount: results.length,
      data: results,
    };
  },
});
```

## Authentication

### Claude.ai Authentication (Recommended)

The SDK automatically handles authentication with Claude.ai for Max/Pro users:

```typescript
// Auto-triggers login if needed
const result = await query({
  prompt: "Help me code",
  options: {
    // Authentication handled automatically
  },
});
```

### API Key Authentication

For direct API access:

```typescript
const result = await query({
  prompt: "Help me code",
  options: {
    env: {
      ANTHROPIC_API_KEY: "sk-ant-...",
    },
  },
});
```

## Session Management

### Resuming Sessions

Continue previous conversations:

```typescript
let sessionId: string | undefined;

// First query
for await (const message of query({ prompt: "Start task" })) {
  if (message.type === "system" && message.subtype === "init") {
    sessionId = message.sessionId;
  }
}

// Resume later
for await (const message of query({
  prompt: "Continue where we left off",
  options: { resume: sessionId },
})) {
  // Continues in same context
}
```

## Error Handling

```typescript
try {
  for await (const message of query({ prompt: "..." })) {
    // Process messages
  }
} catch (error) {
  if (error.name === "AuthenticationError") {
    console.error("Please authenticate with 'claude login'");
  } else if (error.name === "PermissionError") {
    console.error("Permission denied:", error.message);
  } else {
    console.error("Unexpected error:", error);
  }
}
```

## Best Practices

### 1. Progressive Permission Building

Start with default permissions and gradually increase trust:

```typescript
let trustLevel = 0;

const options = {
  canUseTool: async (tool, input) => {
    if (tool === "Read") return { behavior: "allow" };

    if (trustLevel > 3 && !isDangerous(tool, input)) {
      return { behavior: "allow" };
    }

    const approved = await promptUser(tool, input);
    if (approved) trustLevel++;

    return approved ? { behavior: "allow" } : { behavior: "deny" };
  },
};
```

### 2. Environment-Specific MCP

Auto-configure based on project type:

```typescript
async function getAutoMcpServers(projectPath: string) {
  const servers: Record<string, any> = {};

  if (await exists(path.join(projectPath, "package.json"))) {
    servers.nodejs = {
      command: "npx",
      args: ["-y", "@modelcontextprotocol/server-nodejs"],
    };
  }

  if (await exists(path.join(projectPath, ".git"))) {
    servers.git = {
      command: "npx",
      args: ["-y", "@modelcontextprotocol/server-git"],
    };
  }

  return servers;
}
```

### 3. Streaming UI Updates

Provide responsive feedback:

```typescript
let buffer = "";

for await (const message of query({ prompt })) {
  if (message.type === "partial-assistant") {
    buffer += message.delta || "";
    updateUI(buffer);
  } else if (message.type === "assistant") {
    buffer = message.content;
    finalizeUI(buffer);
  }
}
```

### 4. Resource Cleanup

Always clean up resources:

```typescript
const controller = new AbortController();

try {
  for await (const message of query({
    prompt,
    options: { signal: controller.signal },
  })) {
    // Process
  }
} finally {
  // Cleanup
  controller.abort();
}
```

## TypeScript Support

The SDK is fully typed. Import types as needed:

```typescript
import type {
  SDKMessage,
  SDKAssistantMessage,
  SDKUserMessage,
  SDKResultMessage,
  Options,
  PermissionResult,
  ToolInput,
  ToolOutput,
} from "@anthropic-ai/claude-agent-sdk";
```

## Migration from Claude Code SDK

### Breaking Changes

When migrating from `@anthropic-ai/claude-code` to `@anthropic-ai/claude-agent-sdk`, be aware of these breaking changes:

#### 1. System Prompt Behavior

The SDK **no longer uses Claude Code's default system prompt automatically**. If you want Claude Code-like behavior, you must explicitly configure the system prompt:

```typescript
import { query } from "@anthropic-ai/claude-agent-sdk";

for await (const message of query({
  prompt: "fix the build",
  options: {
    systemPrompt: "You are a helpful coding assistant...", // Explicit system prompt
  },
})) {
  // Handle messages
}
```

#### 2. Settings Sources

The SDK **no longer automatically loads filesystem settings by default**. You must explicitly specify settings sources:

```typescript
import { query } from "@anthropic-ai/claude-agent-sdk";

for await (const message of query({
  prompt: "fix the build",
  options: {
    settingSources: ["user", "project", "local"], // Explicitly load settings
  },
})) {
  // Handle messages
}
```

### Migration Steps

**1. Update Package**

```bash
npm uninstall @anthropic-ai/claude-code
npm install @anthropic-ai/claude-agent-sdk
```

**2. Update Imports**

```typescript
// Old
import { query } from "@anthropic-ai/claude-code";

// New
import { query } from "@anthropic-ai/claude-agent-sdk";
```

**3. Add Settings Configuration (if needed)**

If you were relying on automatic settings loading:

```typescript
const options = {
  settingSources: ["user", "project", "local"],
  // ... other options
};
```

**4. Configure System Prompt (if needed)**

If you want Claude Code-like behavior:

```typescript
const options = {
  systemPrompt: "You are a helpful AI assistant that helps with coding tasks...",
  // ... other options
};
```

### Migration Example

**Before (Claude Code SDK)**:

```typescript
import { query } from "@anthropic-ai/claude-code";

for await (const message of query({ prompt: "fix the build" })) {
  console.log(message.content);
}
```

**After (Claude Agent SDK)**:

```typescript
import { query } from "@anthropic-ai/claude-agent-sdk";

for await (const message of query({
  prompt: "fix the build",
  options: {
    settingSources: ["user", "project", "local"],
    systemPrompt: "You are a helpful coding assistant...",
  },
})) {
  console.log(message.content);
}
```

### From CLI to SDK

```typescript
// CLI command
// $ claude "fix the build"

// SDK equivalent
import { query } from "@anthropic-ai/claude-agent-sdk";

for await (const message of query({
  prompt: "fix the build",
})) {
  // Handle messages
}
```

## Additional Resources

- [Official Agent SDK Documentation](https://docs.claude.com/en/api/agent-sdk/overview)
- [TypeScript SDK Documentation](https://docs.claude.com/en/api/agent-sdk/typescript)
- [Migration Guide](https://docs.claude.com/en/docs/claude-code/sdk/migration-guide)
- [GitHub Repository](https://github.com/anthropics/anthropic-sdk-typescript)
- [MCP Specification](https://github.com/modelcontextprotocol/modelcontextprotocol)
- [Discord Community](https://discord.gg/anthropic)

## Version History

- **v2.0+** (2025-01): Renamed to Claude Agent SDK (`@anthropic-ai/claude-agent-sdk`)
  - Breaking: System prompt no longer uses default Claude Code prompt
  - Breaking: Settings sources must be explicitly configured
  - Expanded capabilities beyond coding to support all types of agents
- **v1.x** (2024): Original Claude Code SDK (`@anthropic-ai/claude-code`)
