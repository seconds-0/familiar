// Re-export types from Claude Code SDK
// These types provide proper TypeScript support for the SDK events
export type {
  SDKMessage,
  SDKAssistantMessage,
  SDKPartialAssistantMessage,
  SDKResultMessage,
  SDKSystemMessage,
  SDKUserMessage,
  PermissionResult,
  Options as QueryOptions,
} from "@anthropic-ai/claude-code";

// Application-specific types
export interface Message {
  id: string;
  role: "user" | "assistant" | "system";
  content: string;
  timestamp: Date;
  toolUses?: Array<{
    toolName: string;
    input: unknown;
    output?: unknown;
  }>;
}

export interface SessionData {
  sessionId?: string;
  workingDirectory: string;
  messages: Message[];
  trustLevel?: number;
}

export interface Preferences {
  anthropicApiKey: string;
  shortcut?: string;
  useMockClaude?: boolean;
}

// MCP Server configuration types
export interface McpServerConfig {
  type: "stdio" | "http" | "sse";
  command?: string;
  args?: string[];
  env?: Record<string, string | undefined>;
  url?: string;
  headers?: Record<string, string>;
}
