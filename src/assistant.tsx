import { ActionPanel, Action, List, showToast, Toast, getPreferenceValues, Icon, environment } from "@raycast/api";
import { useState, useEffect, useRef } from "react";

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

// Dynamic import for ESM module
const claudeCode = import("@anthropic-ai/claude-code");

export default function Assistant() {
  const { anthropicApiKey } = getPreferenceValues<Preferences>();
  const [searchText, setSearchText] = useState("");
  const [messages, setMessages] = useState<Message[]>([]);
  const [isLoading, setIsLoading] = useState(false);
  const [sessionData, setSessionData] = useState<SessionData>({
    workingDirectory: process.cwd(),
    messages: [],
  });
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

  // Permission callback - Essential for tool usage
  async function canUseTool(toolName: string, input: unknown): Promise<PermissionResult> {
    // For steel thread, only allow read operations
    const allowedTools = ["Read", "Grep", "Glob"];

    if (allowedTools.includes(toolName)) {
      return {
        behavior: "allow",
        updatedInput: input,
      };
    }

    // Deny write operations for now
    return {
      behavior: "deny",
      message: `${toolName} is not allowed in steel thread MVP`,
    };
  }

  async function handleSubmit() {
    const text = searchText.trim();
    if (!text || isLoading) return;

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
      // Create assistant message placeholder
      const assistantMessage: Message = {
        id: (Date.now() + 1).toString(),
        role: "assistant",
        content: "",
        timestamp: new Date(),
      };
      setMessages((prev) => [...prev, assistantMessage]);

      // Import and use Claude Code SDK
      const { query } = await claudeCode;

      // Get MCP servers configuration
      const mcpServers = await getMcpServers();

      // Query with proper configuration
      const queryIterator = query({
        prompt: text,
        options: {
          includePartialMessages: true,
          resume: sessionData.sessionId,
          model: "default",
          mcpServers,
          canUseTool: canUseTool,
          env: {
            ANTHROPIC_API_KEY: anthropicApiKey,
          },
          signal: abortRef.current.signal,
        },
      });

      for await (const event of queryIterator) {
        // Handle different message types according to SDK docs
        const messageEvent = event as SDKMessage;

        switch (messageEvent.type) {
          case "system": {
            const sysEvent = messageEvent as SDKSystemMessage;
            if (sysEvent.subtype === "init") {
              // Handle both sessionId and session_id variations
              const sid = sysEvent.sessionId || ((sysEvent as Record<string, unknown>).session_id as string);
              if (sid) {
                setSessionData((prev) => ({
                  ...prev,
                  sessionId: sid,
                }));
              }

              // Show system message in development
              if (environment.isDevelopment) {
                const sysMessage: Message = {
                  id: Date.now().toString(),
                  role: "system",
                  content: `Session started with model: ${sysEvent.model || "default"}`,
                  timestamp: new Date(),
                };
                setMessages((prev) => [...prev, sysMessage]);
              }
            }
            break;
          }

          case "partial-assistant": {
            const partialEvent = messageEvent as SDKPartialAssistantMessage;
            // Handle streaming content with immutable updates
            streamBuffer.current += partialEvent.delta || "";
            setMessages((prev) => {
              const updated = [...prev];
              const lastIndex = updated.length - 1;
              if (lastIndex >= 0 && updated[lastIndex].role === "assistant") {
                // Create new object instead of mutating
                updated[lastIndex] = {
                  ...updated[lastIndex],
                  content: streamBuffer.current,
                };
              }
              return updated;
            });
            break;
          }

          case "assistant": {
            const assistantEvent = messageEvent as SDKAssistantMessage;
            // Final complete message with immutable update
            streamBuffer.current = assistantEvent.content || "";
            setMessages((prev) => {
              const updated = [...prev];
              const lastIndex = updated.length - 1;
              if (lastIndex >= 0 && updated[lastIndex].role === "assistant") {
                // Create new object instead of mutating
                updated[lastIndex] = {
                  ...updated[lastIndex],
                  content: assistantEvent.content || "",
                  toolUses: assistantEvent.toolUses,
                };
              }
              return updated;
            });
            // Save immediately on completion
            const key = getSessionKey(sessionData.workingDirectory);
            await saveSessionImmediate(key, {
              ...sessionData,
              messages: messages,
            });
            break;
          }

          case "result": {
            const resultEvent = messageEvent as SDKResultMessage;
            // Handle completion, errors, and interruptions
            if (resultEvent.subtype === "error") {
              await showToast({
                style: Toast.Style.Failure,
                title: "Error",
                message: resultEvent.error || "An error occurred",
              });
            } else if (resultEvent.subtype === "interrupted") {
              debugLog("Query was interrupted");
            } else if (resultEvent.subtype === "success") {
              debugLog("Query completed successfully");
            }
            break;
          }

          default:
            debugLog("Unknown event type:", messageEvent.type);
        }
      }
    } catch (error) {
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
      onSearchTextChange={setSearchText}
      searchBarPlaceholder="Ask me anything... (Press Enter to send)"
      onSearchBarSubmit={handleSubmit}
      navigationTitle="AI Assistant"
    >
      {messages.map((message) => (
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
                  shortcut={{ modifiers: ["cmd"], key: "k" }}
                  style={Action.Style.Destructive}
                />
              </ActionPanel.Section>
            </ActionPanel>
          }
        />
      ))}

      {messages.length === 0 && (
        <List.EmptyView
          icon={Icon.Message}
          title="Welcome to AI Assistant"
          description="Type a question and press Enter. Try: 'What files are in this directory?'"
        />
      )}
    </List>
  );
}
