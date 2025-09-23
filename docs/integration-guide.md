# Claude Code + Raycast Integration Guide

## Overview

This guide demonstrates how to build a Raycast extension that integrates the Claude Code TypeScript SDK, creating an AI assistant that can control your computer through natural language commands.

## Architecture Overview

```
┌─────────────────┐
│   User Input    │
│  (Cmd+Cmd)      │
└────────┬────────┘
         │
┌────────▼────────┐
│  Raycast UI     │
│  (React/TS)     │
└────────┬────────┘
         │
┌────────▼────────┐
│ Claude Code SDK │
│   (query API)   │
└────────┬────────┘
         │
┌────────▼────────┐
│   MCP Servers   │
│ (filesystem,    │
│  search, etc)   │
└─────────────────┘
```

## Setup & Installation

### 1. Create Raycast Extension

```bash
# Create new extension
npx create-raycast-extension ai-assistant

# Navigate to directory
cd ai-assistant

# Install dependencies
npm install
```

### 2. Add Claude Code SDK

```bash
# Install Claude Code SDK
npm install @anthropic-ai/claude-code

# Install additional utilities
npm install zod use-debounce
```

### 3. Update package.json

```json
{
  "name": "ai-assistant",
  "title": "AI Assistant",
  "description": "AI that can control your computer",
  "icon": "icon.png",
  "author": "your-name",
  "categories": ["Productivity", "Developer Tools"],
  "license": "MIT",
  "commands": [
    {
      "name": "assistant",
      "title": "AI Assistant",
      "subtitle": "Chat with AI",
      "description": "Open the AI assistant",
      "mode": "view",
      "preferences": [
        {
          "name": "hotkey",
          "title": "Keyboard Shortcut",
          "description": "Global hotkey to open assistant",
          "type": "textfield",
          "default": "cmd+cmd",
          "required": false
        }
      ]
    }
  ],
  "preferences": [
    {
      "name": "authMethod",
      "title": "Authentication Method",
      "type": "dropdown",
      "data": [
        { "title": "Claude.ai (Recommended)", "value": "claudeai" },
        { "title": "API Key", "value": "apikey" }
      ],
      "default": "claudeai",
      "required": true
    },
    {
      "name": "anthropicApiKey",
      "title": "Anthropic API Key",
      "description": "Only required if using API key auth",
      "type": "password",
      "required": false
    },
    {
      "name": "autoTrustThreshold",
      "title": "Auto Trust After",
      "description": "Number of successful edits before auto-trusting",
      "type": "textfield",
      "default": "3",
      "required": false
    }
  ],
  "dependencies": {
    "@raycast/api": "^1.83.2",
    "@raycast/utils": "^1.17.0",
    "@anthropic-ai/claude-code": "^1.0.0",
    "zod": "^3.22.0",
    "use-debounce": "^10.0.0"
  }
}
```

## Core Implementation

### Main Assistant Component

```typescript
// src/assistant.tsx
import {
  List,
  ActionPanel,
  Action,
  showToast,
  Toast,
  LocalStorage,
  getPreferenceValues,
  Icon,
  confirmAlert,
  Alert,
  environment
} from "@raycast/api";
import { useState, useEffect, useRef, useCallback } from "react";
import { useDebouncedCallback } from "use-debounce";
import {
  query,
  type SDKMessage,
  type SDKAssistantMessage,
  type SDKPartialAssistantMessage,
  type SDKResultMessage,
  type SDKSystemMessage,
  type PermissionResult
} from "@anthropic-ai/claude-code";

interface Preferences {
  authMethod: "claudeai" | "apikey";
  anthropicApiKey?: string;
  autoTrustThreshold: string;
}

interface Message {
  id: string;
  role: "user" | "assistant" | "system";
  content: string;
  timestamp: Date;
  toolUses?: Array<{
    toolName: string;
    input: any;
    output?: any;
  }>;
}

interface SessionData {
  sessionId?: string;
  trustLevel: number;
  workingDirectory: string;
  messages: Message[];
}

export default function Assistant() {
  const preferences = getPreferenceValues<Preferences>();
  const [searchText, setSearchText] = useState("");
  const [isLoading, setIsLoading] = useState(false);
  const [messages, setMessages] = useState<Message[]>([]);
  const [sessionData, setSessionData] = useState<SessionData | null>(null);
  const streamBuffer = useRef("");
  const currentAssistantMessage = useRef<Message | null>(null);

  // Load session for current directory
  useEffect(() => {
    loadSession();
  }, []);

  async function loadSession() {
    const cwd = process.cwd();
    const key = `session_${cwd}`;
    const stored = await LocalStorage.getItem<string>(key);

    if (stored) {
      const data = JSON.parse(stored) as SessionData;
      setSessionData(data);
      setMessages(data.messages);
    } else {
      setSessionData({
        trustLevel: 0,
        workingDirectory: cwd,
        messages: []
      });
    }
  }

  async function saveSession() {
    if (!sessionData) return;

    const cwd = process.cwd();
    const key = `session_${cwd}`;
    await LocalStorage.setItem(key, JSON.stringify({
      ...sessionData,
      messages
    }));
  }

  // Debounced save
  const debouncedSave = useDebouncedCallback(saveSession, 1000);

  // Get authentication environment
  async function getAuthEnvironment(): Promise<Record<string, string>> {
    if (preferences.authMethod === "apikey" && preferences.anthropicApiKey) {
      return { ANTHROPIC_API_KEY: preferences.anthropicApiKey };
    }
    return process.env;
  }

  // Auto-configure MCP servers based on environment
  async function getAutoConfiguredMCP() {
    const fs = await import("fs").then(m => m.promises);
    const path = await import("path");
    const cwd = process.cwd();

    const servers: Record<string, any> = {};

    // Always enable filesystem access
    servers.filesystem = {
      command: "npx",
      args: ["-y", "@modelcontextprotocol/server-filesystem"],
      env: { ALLOWED_PATHS: cwd }
    };

    // Check for project type and add relevant servers
    try {
      const hasPackageJson = await fs.access(
        path.join(cwd, "package.json")
      ).then(() => true).catch(() => false);

      if (hasPackageJson) {
        servers.nodejs = {
          command: "npx",
          args: ["-y", "@modelcontextprotocol/server-nodejs"]
        };
      }

      const hasGit = await fs.access(
        path.join(cwd, ".git")
      ).then(() => true).catch(() => false);

      if (hasGit) {
        servers.git = {
          command: "npx",
          args: ["-y", "@modelcontextprotocol/server-git"]
        };
      }
    } catch (error) {
      console.error("Error detecting project type:", error);
    }

    // Add search server if API key is available
    if (process.env.BRAVE_API_KEY) {
      servers.braveSearch = {
        type: "sse",
        url: "https://api.search.brave.com/mcp/sse",
        headers: { "X-API-KEY": process.env.BRAVE_API_KEY }
      };
    }

    return servers;
  }

  // Smart permission handler with progressive trust
  async function smartPermissionHandler(
    toolName: string,
    input: any
  ): Promise<PermissionResult> {
    const trustLevel = sessionData?.trustLevel || 0;
    const autoTrustThreshold = parseInt(
      preferences.autoTrustThreshold || "3"
    );

    // Always allow read operations
    if (toolName === "Read" || toolName === "Grep" || toolName === "Glob") {
      return { behavior: "allow", updatedInput: input };
    }

    // Check if it's a safe bash command
    if (toolName === "Bash") {
      const safeCommands = [
        "ls", "pwd", "echo", "cat", "grep", "find",
        "git status", "git diff", "git log",
        "npm list", "npm test"
      ];

      const command = input.command?.toLowerCase() || "";
      const isSafe = safeCommands.some(safe =>
        command.startsWith(safe)
      );

      if (isSafe) {
        return { behavior: "allow", updatedInput: input };
      }
    }

    // Auto-approve in trusted projects
    if (trustLevel >= autoTrustThreshold && !isDangerous(toolName, input)) {
      return { behavior: "allow", updatedInput: input };
    }

    // Show confirmation for edits
    if (toolName === "Edit" || toolName === "Write" || toolName === "MultiEdit") {
      const preview = generatePreview(toolName, input);

      const confirmed = await confirmAlert({
        title: "Apply this change?",
        message: preview,
        icon: getToolIcon(toolName),
        primaryAction: {
          title: "Apply",
          style: Alert.ActionStyle.Default
        },
        dismissAction: {
          title: "Skip"
        }
      });

      if (confirmed) {
        await incrementTrust();
        return { behavior: "allow", updatedInput: input };
      }

      return { behavior: "deny", message: "User skipped" };
    }

    // Dangerous operations always require confirmation
    if (isDangerous(toolName, input)) {
      const confirmed = await confirmAlert({
        title: "⚠️ Dangerous Operation",
        message: `This will ${describeDanger(toolName, input)}. Are you sure?`,
        icon: Icon.Warning,
        primaryAction: {
          title: "Proceed",
          style: Alert.ActionStyle.Destructive
        },
        dismissAction: {
          title: "Cancel"
        }
      });

      return confirmed
        ? { behavior: "allow", updatedInput: input }
        : { behavior: "deny", message: "User cancelled dangerous operation" };
    }

    // Default: ask for permission
    const confirmed = await confirmAlert({
      title: `Allow ${toolName}?`,
      message: JSON.stringify(input, null, 2).slice(0, 200),
      icon: getToolIcon(toolName),
      primaryAction: {
        title: "Allow",
        style: Alert.ActionStyle.Default
      },
      dismissAction: {
        title: "Deny"
      }
    });

    return confirmed
      ? { behavior: "allow", updatedInput: input }
      : { behavior: "deny", message: "User denied permission" };
  }

  // Helper functions
  function isDangerous(toolName: string, input: any): boolean {
    if (toolName === "Bash") {
      const dangerous = ["rm -rf", "sudo", "chmod 777", "curl | sh"];
      const command = input.command || "";
      return dangerous.some(d => command.includes(d));
    }

    if (toolName === "Write" || toolName === "Edit") {
      const path = input.file_path || "";
      return path.includes(".env") ||
             path.includes("secrets") ||
             path.includes("credentials");
    }

    return false;
  }

  function describeDanger(toolName: string, input: any): string {
    if (toolName === "Bash" && input.command?.includes("rm -rf")) {
      return "permanently delete files";
    }
    if (toolName === "Bash" && input.command?.includes("sudo")) {
      return "run with administrator privileges";
    }
    return "perform a potentially dangerous operation";
  }

  function generatePreview(toolName: string, input: any): string {
    if (toolName === "Edit" || toolName === "MultiEdit") {
      return `File: ${input.file_path}\n\nChanges:\n${
        input.old_string?.slice(0, 100)
      }\n→\n${input.new_string?.slice(0, 100)}`;
    }

    if (toolName === "Write") {
      return `File: ${input.file_path}\n\nContent preview:\n${
        input.content?.slice(0, 200)
      }...`;
    }

    return JSON.stringify(input, null, 2).slice(0, 300);
  }

  function getToolIcon(toolName: string): Icon {
    const icons: Record<string, Icon> = {
      Read: Icon.Document,
      Write: Icon.Pencil,
      Edit: Icon.Pencil,
      Bash: Icon.Terminal,
      WebSearch: Icon.Globe,
      WebFetch: Icon.Download
    };
    return icons[toolName] || Icon.Cog;
  }

  async function incrementTrust() {
    if (!sessionData) return;

    const newTrustLevel = sessionData.trustLevel + 1;
    setSessionData({ ...sessionData, trustLevel: newTrustLevel });

    const threshold = parseInt(preferences.autoTrustThreshold || "3");
    if (newTrustLevel === threshold) {
      await showToast({
        style: Toast.Style.Success,
        title: "Project Trusted",
        message: "Future edits will be faster"
      });
    }

    await debouncedSave();
  }

  // Handle streaming messages
  async function handleStreamingMessage(message: SDKMessage) {
    switch (message.type) {
      case "system":
        if (message.subtype === "init") {
          setSessionData(prev => ({
            ...prev!,
            sessionId: message.sessionId
          }));

          const sysMessage: Message = {
            id: crypto.randomUUID(),
            role: "system",
            content: `Session started. Model: ${message.model}`,
            timestamp: new Date()
          };
          setMessages(prev => [...prev, sysMessage]);
        }
        break;

      case "partial-assistant":
        if (!currentAssistantMessage.current) {
          currentAssistantMessage.current = {
            id: crypto.randomUUID(),
            role: "assistant",
            content: "",
            timestamp: new Date()
          };
          setMessages(prev => [...prev, currentAssistantMessage.current!]);
        }

        currentAssistantMessage.current.content += message.delta || "";
        setMessages(prev =>
          prev.map(m =>
            m.id === currentAssistantMessage.current?.id
              ? currentAssistantMessage.current
              : m
          )
        );
        break;

      case "assistant":
        if (currentAssistantMessage.current) {
          currentAssistantMessage.current.content = message.content;
          currentAssistantMessage.current.toolUses = message.toolUses;
          setMessages(prev =>
            prev.map(m =>
              m.id === currentAssistantMessage.current?.id
                ? currentAssistantMessage.current!
                : m
            )
          );
        } else {
          const assistantMessage: Message = {
            id: crypto.randomUUID(),
            role: "assistant",
            content: message.content,
            timestamp: new Date(),
            toolUses: message.toolUses
          };
          setMessages(prev => [...prev, assistantMessage]);
        }
        currentAssistantMessage.current = null;
        break;

      case "result":
        if (message.subtype === "error") {
          await showToast({
            style: Toast.Style.Failure,
            title: "Error",
            message: message.error || "Unknown error"
          });
        }
        break;
    }

    await debouncedSave();
  }

  // Send message to Claude
  async function sendMessage() {
    const text = searchText.trim();
    if (!text || isLoading) return;

    setSearchText("");
    const userMessage: Message = {
      id: crypto.randomUUID(),
      role: "user",
      content: text,
      timestamp: new Date()
    };
    setMessages(prev => [...prev, userMessage]);

    setIsLoading(true);
    currentAssistantMessage.current = null;

    try {
      const mcpServers = await getAutoConfiguredMCP();
      const env = await getAuthEnvironment();

      for await (const message of query({
        prompt: text,
        options: {
          resume: sessionData?.sessionId,
          includePartialMessages: true,
          permissionMode: "default",
          canUseTool: smartPermissionHandler,
          mcpServers,
          env
        }
      })) {
        await handleStreamingMessage(message);
      }
    } catch (error) {
      console.error("Query error:", error);
      await showToast({
        style: Toast.Style.Failure,
        title: "Error",
        message: error instanceof Error ? error.message : "Unknown error"
      });
    } finally {
      setIsLoading(false);
      await saveSession();
    }
  }

  // Render message content with formatting
  function renderMessageContent(message: Message): string {
    let content = message.content;

    if (message.toolUses && message.toolUses.length > 0) {
      content += "\n\n**Tools used:**";
      for (const tool of message.toolUses) {
        content += `\n- ${tool.toolName}`;
      }
    }

    return content;
  }

  // Get message icon
  function getMessageIcon(message: Message): Icon {
    if (message.role === "user") return Icon.Person;
    if (message.role === "system") return Icon.Cog;
    return Icon.Stars;
  }

  return (
    <List
      isLoading={isLoading}
      searchText={searchText}
      onSearchTextChange={setSearchText}
      searchBarPlaceholder="What do you want me to do?"
      throttle={false}
      actions={
        !isLoading && (
          <ActionPanel>
            <Action
              title="Send Message"
              icon={Icon.PaperPlane}
              onAction={sendMessage}
              shortcut={{ modifiers: ["cmd"], key: "return" }}
            />
            <Action
              title="Clear Session"
              icon={Icon.Trash}
              onAction={async () => {
                setMessages([]);
                setSessionData(prev => ({
                  ...prev!,
                  sessionId: undefined,
                  messages: []
                }));
                await saveSession();
              }}
              shortcut={{ modifiers: ["cmd", "shift"], key: "delete" }}
            />
          </ActionPanel>
        )
      }
    >
      {messages.length === 0 ? (
        <List.EmptyView
          icon={Icon.Message}
          title="Start a conversation"
          description="Type what you want me to do and press Enter"
        />
      ) : (
        messages.map((message) => (
          <List.Item
            key={message.id}
            title={message.role === "user" ? "You" : "Assistant"}
            subtitle={renderMessageContent(message)}
            icon={getMessageIcon(message)}
            accessories={[
              {
                date: message.timestamp,
                tooltip: message.timestamp.toLocaleString()
              }
            ]}
          />
        ))
      )}
    </List>
  );
}
```

### Advanced Features Implementation

#### 1. Context-Aware Suggestions

```typescript
// src/utils/suggestions.ts
interface Suggestion {
  title: string;
  action: () => void;
  icon: Icon;
}

export function getContextualSuggestions(
  lastMessage: Message | null,
  workingDirectory: string
): Suggestion[] {
  const suggestions: Suggestion[] = [];

  // Error context
  if (lastMessage?.content.includes("error")) {
    suggestions.push({
      title: "Fix this error",
      action: () => sendMessage("Fix the error above"),
      icon: Icon.Bug
    });
  }

  // File context
  if (lastMessage?.content.includes("file")) {
    suggestions.push({
      title: "Open in editor",
      action: () => sendMessage("Open this file in my editor"),
      icon: Icon.Document
    });
  }

  // Git context
  if (workingDirectory.includes(".git")) {
    suggestions.push({
      title: "Show git status",
      action: () => sendMessage("What's the git status?"),
      icon: Icon.Branch
    });
  }

  return suggestions;
}
```

#### 2. File Preview Component

```typescript
// src/components/FilePreview.tsx
import { Detail, ActionPanel, Action } from "@raycast/api";

interface FilePreviewProps {
  filePath: string;
  content: string;
  language?: string;
}

export function FilePreview({
  filePath,
  content,
  language = "text"
}: FilePreviewProps) {
  const markdown = `
## ${filePath}

\`\`\`${language}
${content}
\`\`\`
  `;

  return (
    <Detail
      markdown={markdown}
      actions={
        <ActionPanel>
          <Action.CopyToClipboard
            title="Copy Content"
            content={content}
          />
          <Action.OpenWith
            title="Open in Editor"
            path={filePath}
          />
        </ActionPanel>
      }
    />
  );
}
```

#### 3. Inline Diff Viewer

```typescript
// src/components/DiffViewer.tsx
import { List, Color } from "@raycast/api";

interface DiffLine {
  type: "add" | "remove" | "context";
  content: string;
  lineNumber: number;
}

export function DiffViewer({ diff }: { diff: DiffLine[] }) {
  return (
    <List>
      {diff.map((line, index) => (
        <List.Item
          key={index}
          title={`${line.lineNumber}: ${line.content}`}
          icon={{
            source: line.type === "add" ? Icon.Plus :
                    line.type === "remove" ? Icon.Minus :
                    Icon.Dot,
            tintColor: line.type === "add" ? Color.Green :
                      line.type === "remove" ? Color.Red :
                      Color.SecondaryText
          }}
        />
      ))}
    </List>
  );
}
```

## Session Management

### Per-Directory Sessions

```typescript
// src/utils/session.ts
import { LocalStorage } from "@raycast/api";

export interface DirectorySession {
  path: string;
  sessionId?: string;
  messages: Message[];
  trustLevel: number;
  lastAccessed: Date;
  mcpServers?: Record<string, any>;
}

export class SessionManager {
  private static KEY_PREFIX = "session_";

  static async getSession(path: string): Promise<DirectorySession | null> {
    const key = `${this.KEY_PREFIX}${path}`;
    const stored = await LocalStorage.getItem<string>(key);
    return stored ? JSON.parse(stored) : null;
  }

  static async saveSession(session: DirectorySession): Promise<void> {
    const key = `${this.KEY_PREFIX}${session.path}`;
    session.lastAccessed = new Date();
    await LocalStorage.setItem(key, JSON.stringify(session));
  }

  static async getAllSessions(): Promise<DirectorySession[]> {
    const all = await LocalStorage.allItems();
    const sessions: DirectorySession[] = [];

    for (const [key, value] of Object.entries(all)) {
      if (key.startsWith(this.KEY_PREFIX)) {
        sessions.push(JSON.parse(value as string));
      }
    }

    return sessions.sort((a, b) =>
      b.lastAccessed.getTime() - a.lastAccessed.getTime()
    );
  }

  static async cleanOldSessions(daysToKeep = 30): Promise<void> {
    const cutoff = new Date();
    cutoff.setDate(cutoff.getDate() - daysToKeep);

    const sessions = await this.getAllSessions();
    for (const session of sessions) {
      if (new Date(session.lastAccessed) < cutoff) {
        await LocalStorage.removeItem(
          `${this.KEY_PREFIX}${session.path}`
        );
      }
    }
  }
}
```

## Trust System

### Progressive Trust Building

```typescript
// src/utils/trust.ts
export enum TrustLevel {
  Untrusted = 0,
  Minimal = 1,
  Moderate = 3,
  High = 5,
  Full = 10
}

export interface TrustPolicy {
  level: TrustLevel;
  allowedTools: string[];
  requireConfirmation: string[];
  autoApprove: string[];
}

export const TRUST_POLICIES: TrustPolicy[] = [
  {
    level: TrustLevel.Untrusted,
    allowedTools: ["Read", "Grep", "Glob"],
    requireConfirmation: ["Edit", "Write", "Bash"],
    autoApprove: []
  },
  {
    level: TrustLevel.Minimal,
    allowedTools: ["Read", "Grep", "Glob", "Bash"],
    requireConfirmation: ["Edit", "Write"],
    autoApprove: ["Read", "Grep"]
  },
  {
    level: TrustLevel.Moderate,
    allowedTools: ["*"],
    requireConfirmation: ["Write", "Bash"],
    autoApprove: ["Read", "Edit", "Grep"]
  },
  {
    level: TrustLevel.High,
    allowedTools: ["*"],
    requireConfirmation: [],
    autoApprove: ["Read", "Edit", "Write", "safe:Bash"]
  }
];

export function getTrustPolicy(trustLevel: number): TrustPolicy {
  return TRUST_POLICIES.find(p => p.level <= trustLevel) ||
         TRUST_POLICIES[0];
}
```

## Error Handling

### Comprehensive Error Management

```typescript
// src/utils/errors.ts
export class ClaudeCodeError extends Error {
  constructor(
    message: string,
    public code: string,
    public details?: any
  ) {
    super(message);
    this.name = "ClaudeCodeError";
  }
}

export async function handleError(error: any): Promise<void> {
  console.error("Error:", error);

  if (error.code === "AUTH_REQUIRED") {
    await showToast({
      style: Toast.Style.Failure,
      title: "Authentication Required",
      message: "Please authenticate with Claude",
      primaryAction: {
        title: "Open Claude",
        onAction: () => open("claude://login")
      }
    });
  } else if (error.code === "RATE_LIMIT") {
    await showToast({
      style: Toast.Style.Failure,
      title: "Rate Limited",
      message: "Please wait before trying again"
    });
  } else if (error.code === "PERMISSION_DENIED") {
    await showToast({
      style: Toast.Style.Failure,
      title: "Permission Denied",
      message: error.message
    });
  } else {
    await showToast({
      style: Toast.Style.Failure,
      title: "Error",
      message: error.message || "An unexpected error occurred"
    });
  }
}
```

## Testing

### Unit Tests

```typescript
// src/__tests__/assistant.test.ts
import { render, fireEvent, waitFor } from "@testing-library/react";
import { query } from "@anthropic-ai/claude-code";
import Assistant from "../assistant";

jest.mock("@anthropic-ai/claude-code");
jest.mock("@raycast/api");

describe("Assistant", () => {
  it("sends messages to Claude", async () => {
    const mockQuery = query as jest.Mock;
    mockQuery.mockReturnValue({
      async *[Symbol.asyncIterator]() {
        yield {
          type: "assistant",
          content: "Hello from Claude"
        };
      }
    });

    const { getByPlaceholderText, getByText } = render(<Assistant />);

    const input = getByPlaceholderText("What do you want me to do?");
    fireEvent.change(input, { target: { value: "Hello" } });
    fireEvent.submit(input);

    await waitFor(() => {
      expect(getByText("Hello from Claude")).toBeInTheDocument();
    });
  });
});
```

## Deployment

### 1. Build for Production

```bash
# Run tests
npm test

# Lint code
npm run lint

# Build extension
npm run build
```

### 2. Package Extension

```json
// raycast-env.d.ts
/// <reference types="@raycast/api">

declare namespace NodeJS {
  interface ProcessEnv {
    ANTHROPIC_API_KEY?: string;
    BRAVE_API_KEY?: string;
  }
}
```

### 3. Store Submission Checklist

- [ ] Icon: 512x512px PNG
- [ ] Screenshots: At least 2 showing the assistant in action
- [ ] README: Clear documentation with examples
- [ ] Categories: "Productivity", "Developer Tools"
- [ ] Keywords: "ai", "assistant", "claude", "automation"
- [ ] Test all permission flows
- [ ] Verify error handling
- [ ] Check performance (< 1s initial load)

## Best Practices

### 1. Responsive UI

```typescript
// Show immediate feedback
const [isThinking, setIsThinking] = useState(false);

// Indicate AI is processing
if (isThinking) {
  return <List.Item title="AI is thinking..." icon={Icon.Hourglass} />;
}
```

### 2. Smart Caching

```typescript
// Cache MCP server configurations
const mcpCache = new Map<string, any>();

async function getCachedMCP(path: string) {
  if (!mcpCache.has(path)) {
    mcpCache.set(path, await detectMCPServers(path));
  }
  return mcpCache.get(path);
}
```

### 3. Graceful Degradation

```typescript
// Fallback when Claude is unavailable
if (!isClaudeAvailable) {
  return (
    <List.EmptyView
      icon={Icon.ExclamationMark}
      title="Claude Unavailable"
      description="Please check your connection and try again"
      actions={
        <ActionPanel>
          <Action
            title="Retry"
            onAction={retry}
          />
        </ActionPanel>
      }
    />
  );
}
```

## Troubleshooting

### Common Issues

1. **Authentication fails**: Check Claude.ai login or API key
2. **MCP servers not starting**: Verify npx is available
3. **Permissions denied**: Check trust level and settings
4. **Session not persisting**: Verify LocalStorage permissions
5. **Streaming not working**: Check WebSocket connection

### Debug Mode

```typescript
// Enable debug logging
const DEBUG = environment.isDevelopment;

function debug(...args: any[]) {
  if (DEBUG) {
    console.log("[AI Assistant]", ...args);
  }
}
```

## Resources

- [Claude Code SDK Docs](https://docs.claude.com/en/docs/claude-code/sdk/sdk-typescript)
- [Raycast API Docs](https://developers.raycast.com)
- [MCP Specification](https://github.com/modelcontextprotocol/modelcontextprotocol)
- [Example Extensions](https://github.com/raycast/extensions)