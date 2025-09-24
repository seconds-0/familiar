import { ActionPanel, Action, List, showToast, Toast, getPreferenceValues, Icon, environment } from "@raycast/api";
import { useState, useEffect, useRef } from "react";
import os from "os";
import fs from "fs";
import path from "path";

// Import utilities and types
import type {
  Message,
  SessionData,
  Preferences,
  SDKMessage,
  SDKSystemMessage,
  SDKPartialAssistantMessage,
  SDKAssistantMessage,
  SDKResultMessage,
  PermissionResult,
} from "./utils/types";
import { saveSessionDebounced, saveSessionImmediate, loadSession, clearSession, getSessionKey } from "./utils/session";
import { getMcpServers, resolveWorkingPath, debugLog } from "./utils/mcp";
import { resolveClaudeCliPath } from "./utils/claude";

function createMockAssistantResponse(prompt: string): Message {
  return {
    id: `${Date.now()}-mock`,
    role: "assistant",
    content: `Mock response for: ${prompt}`,
    timestamp: new Date(),
  };
}

// Use Anthropic API directly instead of Claude Code SDK
import Anthropic from "@anthropic-ai/sdk";

export default function Assistant() {
  const { anthropicApiKey, useMockClaude } = getPreferenceValues<Preferences>();
  const [searchText, setSearchText] = useState("");
  const [messages, setMessages] = useState<Message[]>([]);
  const [isLoading, setIsLoading] = useState(false);
  const [sessionData, setSessionData] = useState<SessionData>({
    workingDirectory: process.cwd(),
    messages: [],
  });
  const [claudeCliPath, setClaudeCliPath] = useState<string | undefined>();
  const [cliError, setCliError] = useState<string | undefined>();
  const streamBuffer = useRef("");
  const abortRef = useRef<AbortController | null>(null);

  // Load saved session on mount for current directory
  useEffect(() => {
    async function initSession() {
      try {
        const workingPath = await resolveWorkingPath();
        const key = getSessionKey(workingPath);
        const savedData = await loadSession(key);

        if (savedData) {
          setSessionData(savedData);
          setMessages(savedData.messages || []);
        } else {
          setSessionData({
            workingDirectory: workingPath,
            messages: [],
          });
        }
      } catch (error) {
        debugLog("Failed to load session:", error);
      }
    }
    initSession();
  }, []);

  useEffect(() => {
    let isMounted = true;

    async function loadCliPath() {
      try {
        const path = await resolveClaudeCliPath({
          retries: 5,
          delayMs: 500,
          debug: (...args) => debugLog("CLI Resolver", ...args),
        });

        if (!isMounted) {
          return;
        }

        setClaudeCliPath(path);
        setCliError(undefined);
      } catch (error) {
        if (!isMounted) {
          return;
        }

        const message = error instanceof Error ? error.message : String(error);
        setCliError(message);
        debugLog("Failed to locate Claude Code CLI:", message);
      }

      const socketsDir = path.join(os.tmpdir(), "claude-sockets");
      try {
        if (!fs.existsSync(socketsDir)) {
          fs.mkdirSync(socketsDir, { recursive: true });
        }
      } catch (error) {
        debugLog("Failed to prepare socket directory", error);
      }
    }

    loadCliPath();

    return () => {
      isMounted = false;
    };
  }, []);

  // Cleanup on unmount
  useEffect(() => {
    return () => {
      abortRef.current?.abort();
    };
  }, []);

  // Save session when messages change (debounced)
  useEffect(() => {
    if (messages.length > 0 || sessionData.sessionId) {
      const key = getSessionKey(sessionData.workingDirectory);
      const dataToSave: SessionData = {
        ...sessionData,
        messages,
      };
      saveSessionDebounced(key, dataToSave);
    }
  }, [messages, sessionData]);

  // Custom tool implementations using Raycast APIs
  async function implementEditTool(input: any): Promise<any> {
    try {
      const { file_path, old_string, new_string } = input;
      const fs = require('fs').promises;
      const path = require('path');

      // Use Node.js fs APIs directly
      const fullPath = path.resolve(file_path);
      const content = await fs.readFile(fullPath, 'utf8');

      // Perform the edit
      const updatedContent = content.replace(old_string, new_string);
      await fs.writeFile(fullPath, updatedContent, 'utf8');

      return {
        success: true,
        message: `File ${file_path} updated successfully`
      };
    } catch (error) {
      throw new Error(`Failed to edit file: ${error.message}`);
    }
  }

  async function implementReadTool(input: any): Promise<any> {
    try {
      const { file_path } = input;
      const fs = require('fs').promises;
      const path = require('path');

      const fullPath = path.resolve(file_path);
      const content = await fs.readFile(fullPath, 'utf8');

      return {
        success: true,
        content: content
      };
    } catch (error) {
      throw new Error(`Failed to read file: ${error.message}`);
    }
  }

  async function implementGrepTool(input: any): Promise<any> {
    try {
      const { pattern, path: searchPath = '.', glob } = input;
      const fs = require('fs').promises;
      const path = require('path');

      // Simple file search implementation
      const results: Array<{file: string, line: number, content: string}> = [];

      async function searchInFile(filePath: string): Promise<void> {
        try {
          const content = await fs.readFile(filePath, 'utf8');
          const lines = content.split('\n');

          lines.forEach((line, index) => {
            if (line.includes(pattern)) {
              results.push({
                file: filePath,
                line: index + 1,
                content: line.trim()
              });
            }
          });
        } catch (error) {
          // Skip files that can't be read
        }
      }

      // This is a simplified implementation - would need glob support
      const searchDir = path.resolve(searchPath);
      const item = await fs.stat(searchDir);

      if (item.isFile()) {
        await searchInFile(searchDir);
      } else {
        // Would need to implement directory traversal
        console.log("Directory search not implemented yet");
      }

      return {
        success: true,
        results: results
      };
    } catch (error) {
      throw new Error(`Failed to search: ${error.message}`);
    }
  }

  // Permission callback - Allow tools for custom implementation
  async function canUseTool(toolName: string, input: unknown): Promise<PermissionResult> {
    // Allow all tools since we'll implement them with Raycast APIs
    const allowedTools = ["Read", "Edit", "Grep", "Glob", "Bash"];

    if (allowedTools.includes(toolName)) {
      return {
        behavior: "allow",
        updatedInput: input,
      };
    }

    return {
      behavior: "deny",
      message: `${toolName} is not implemented`,
    };
  }

  // Execute tool calls using custom implementations
  async function executeTool(toolUseBlock: any): Promise<string> {
    try {
      const { name, input } = toolUseBlock.function;

      console.log(`[Tool Execution] Executing ${name} with:`, input);

      switch (name) {
        case "edit_file":
          const editResult = await implementEditTool(input);
          return JSON.stringify(editResult);

        case "read_file":
          const readResult = await implementReadTool(input);
          return JSON.stringify(readResult);

        case "grep_search":
          const grepResult = await implementGrepTool(input);
          return JSON.stringify(grepResult);

        default:
          return JSON.stringify({
            success: false,
            error: `Unknown tool: ${name}`
          });
      }
    } catch (error) {
      console.error(`[Tool Execution] Error in ${toolUseBlock.function?.name}:`, error);
      return JSON.stringify({
        success: false,
        error: error instanceof Error ? error.message : String(error)
      });
    }
  }

  async function handleSubmit() {
    console.log("[handleSubmit] Called with searchText:", searchText);
    console.log("[handleSubmit] isLoading:", isLoading);

    const text = searchText.trim();
    if (!text || isLoading) {
      console.log("[handleSubmit] Early return - empty text or loading");
      return;
    }

    if (useMockClaude) {
      const mockMessage = createMockAssistantResponse(text);
      setMessages((prev) => [...prev, mockMessage]);
      setIsLoading(false);
      return;
    }

    if (!claudeCliPath) {
      const message = cliError ?? "Claude Code CLI not available yet. Retrying...";
      await showToast({
        style: Toast.Style.Animated,
        title: "Claude CLI",
        message,
      });

      try {
        const path = await resolveClaudeCliPath({
          retries: 5,
          delayMs: 500,
          debug: (...args) => debugLog("CLI Resolver Retry", ...args),
        });
        setClaudeCliPath(path);
        setCliError(undefined);
      } catch (error) {
        const errMessage = error instanceof Error ? error.message : String(error);
        setCliError(errMessage);
        await showToast({
          style: Toast.Style.Failure,
          title: "Claude CLI Missing",
          message: errMessage,
        });
        return;
      }
    }

    console.log("[handleSubmit] Processing message:", text);

    // Cancel any existing query
    abortRef.current?.abort();
    abortRef.current = new AbortController();

    // Add user message
    const userMessage: Message = {
      id: Date.now().toString(),
      role: "user",
      content: text,
      timestamp: new Date(),
    };
    setMessages((prev) => [...prev, userMessage]);
    setSearchText("");
    setIsLoading(true);
    streamBuffer.current = "";

    try {
      console.log("[handleSubmit] Starting query...");
      // Create assistant message placeholder
      const assistantMessage: Message = {
        id: (Date.now() + 1).toString(),
        role: "assistant",
        content: "",
        timestamp: new Date(),
      };
      setMessages((prev) => [...prev, assistantMessage]);

      // Create Anthropic client
      const client = new Anthropic({
        apiKey: anthropicApiKey,
      });

      // Build conversation history with current message
      const messages = [
        // Include previous conversation context
        ...sessionData.messages.slice(-10).map(msg => ({
          role: msg.role === "assistant" ? "assistant" : "user",
          content: msg.content
        })),
        // Add current user message
        { role: "user", content: text }
      ];

      // Make API call to Anthropic with tool support
      try {
        const response = await client.messages.create({
          model: "claude-3-opus-20240229",
          max_tokens: 4096,
          messages: messages,
          tools: [
            {
              type: "function",
              function: {
                name: "edit_file",
                description: "Edit a file by replacing old_string with new_string",
                parameters: {
                  type: "object",
                  properties: {
                    file_path: { type: "string", description: "Path to the file" },
                    old_string: { type: "string", description: "Text to replace" },
                    new_string: { type: "string", description: "New text to insert" }
                  },
                  required: ["file_path", "old_string", "new_string"]
                }
              }
            },
            {
              type: "function",
              function: {
                name: "read_file",
                description: "Read the contents of a file",
                parameters: {
                  type: "object",
                  properties: {
                    file_path: { type: "string", description: "Path to the file" }
                  },
                  required: ["file_path"]
                }
              }
            },
            {
              type: "function",
              function: {
                name: "grep_search",
                description: "Search for text within files",
                parameters: {
                  type: "object",
                  properties: {
                    pattern: { type: "string", description: "Pattern to search for" },
                    path: { type: "string", description: "Directory or file to search", default: "." }
                  },
                  required: ["pattern"]
                }
              }
            }
          ]
        });

        // Handle response - check if it contains tool calls
        let assistantContent = "";
        if (response.content.some(block => block.type === "tool_use")) {
          // Get the first tool use block
          const toolUseBlock = response.content.find(block => block.type === "tool_use");
          if (!toolUseBlock) {
            throw new Error("Tool use block not found");
          }

          // Execute the tool
          const toolResult = await executeTool(toolUseBlock);

          // Add tool result back to conversation and get final response
          const finalResponse = await client.messages.create({
            model: "claude-3-opus-20240229",
            max_tokens: 4096,
            messages: [
              ...messages,
              { role: "assistant", content: response.content },
              {
                role: "user",
                content: [{
                  type: "tool_result",
                  tool_use_id: toolUseBlock.id,
                  content: toolResult
                }]
              }
            ]
          });

          // Extract text content from final response
          const finalContent = finalResponse.content.find(block => block.type === "text");
          assistantContent = finalContent ? finalContent.text : "Tool executed successfully";
        } else {
          // Direct response without tool calls
          const contentBlock = response.content.find(block => block.type === "text");
          assistantContent = contentBlock ? contentBlock.text : "";
        }

        // Create and save assistant response
        const assistantResponse: Message = {
          id: Date.now().toString(),
          role: "assistant",
          content: assistantContent,
          timestamp: new Date(),
        };

        setMessages((prev) => {
          const updated = [...prev, assistantResponse];
          const key = getSessionKey(sessionData.workingDirectory);
          saveSessionImmediate(key, {
            ...sessionData,
            messages: updated,
          });
          return updated;
        });

      } catch (error) {
        console.error("[handleSubmit] Anthropic API error:", error);
        await showToast({
          style: Toast.Style.Failure,
          title: "API Error",
          message: error instanceof Error ? error.message : "Unknown error",
        });
      }
    } catch (error) {
      console.error("[handleSubmit] Error caught:", error);
      // Handle specific error types
      const errorMessage = error instanceof Error ? error.message : String(error);
      if (errorMessage.includes("AUTH")) {
        await showToast({
          style: Toast.Style.Failure,
          title: "Authentication Error",
          message: "Please check your API key",
        });
      } else {
        await showToast({
          style: Toast.Style.Failure,
          title: "Error",
          message: errorMessage,
        });
      }

      // Remove empty assistant message on error
      setMessages((prev) => {
        if (prev[prev.length - 1]?.content === "") {
          return prev.slice(0, -1);
        }
        return prev;
      });
    } finally {
      console.log("[handleSubmit] Completed");
      setIsLoading(false);
    }
  }

  async function handleClear() {
    // Cancel any in-flight queries
    abortRef.current?.abort();

    setMessages([]);
    setSessionData((prev) => ({
      ...prev,
      sessionId: undefined,
      messages: [],
    }));

    const key = getSessionKey(sessionData.workingDirectory);
    await clearSession(key);

    await showToast({
      style: Toast.Style.Success,
      title: "Conversation cleared",
    });
  }

  return (
    <List
      isLoading={isLoading}
      searchText={searchText}
      onSearchTextChange={(text) => {
        console.log("[onSearchTextChange] New text:", text);
        setSearchText(text);
      }}
      searchBarPlaceholder="Ask me anything... (Press Enter to send)"
      onSearchBarSubmit={() => {
        console.log("[onSearchBarSubmit] Triggered");
        handleSubmit();
      }}
      navigationTitle="AI Assistant"
    >
      {messages.length === 0 ? (
        // When no messages, show a placeholder item with action
        <List.Item
          title="Welcome to AI Assistant"
          subtitle="Type a question above and press Enter to send"
          icon={Icon.Message}
          actions={
            <ActionPanel>
              <ActionPanel.Section>
                <Action
                  title="Send Message"
                  onAction={() => {
                    console.log("[List.Item Action] Triggered with searchText:", searchText);
                    handleSubmit();
                  }}
                />
              </ActionPanel.Section>
              <ActionPanel.Section>
                <Action
                  title="Clear Conversation"
                  onAction={handleClear}
                  icon={Icon.Trash}
                  shortcut={{ modifiers: ["cmd", "shift"], key: "c" }}
                  style={Action.Style.Destructive}
                />
              </ActionPanel.Section>
            </ActionPanel>
          }
        />
      ) : (
        // Show actual messages
        messages.map((message) => (
          <List.Item
            key={message.id}
            icon={message.role === "user" ? Icon.Person : message.role === "assistant" ? Icon.Stars : Icon.Cog}
            title={message.role === "user" ? "You" : message.role === "assistant" ? "AI Assistant" : "System"}
            subtitle={message.content}
            accessories={[
              {
                date: message.timestamp,
                tooltip: message.timestamp.toLocaleString(),
              },
            ]}
            actions={
              <ActionPanel>
                <ActionPanel.Section>
                  <Action
                    title="Send Message"
                    onAction={() => {
                      console.log("[Message Action] Triggered with searchText:", searchText);
                      handleSubmit();
                    }}
                    icon={Icon.Message}
                    shortcut={{ modifiers: ["cmd"], key: "return" }}
                  />
                  <Action.CopyToClipboard
                    title="Copy Message"
                    content={message.content}
                    shortcut={{ modifiers: ["cmd"], key: "c" }}
                  />
                </ActionPanel.Section>
                <ActionPanel.Section>
                  <Action
                    title="Clear Conversation"
                    onAction={handleClear}
                    icon={Icon.Trash}
                    shortcut={{ modifiers: ["cmd", "shift"], key: "c" }}
                    style={Action.Style.Destructive}
                  />
                </ActionPanel.Section>
              </ActionPanel>
            }
          />
        ))
      )}
    </List>
  );
}
