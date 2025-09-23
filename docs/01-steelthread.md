# Steel Thread Implementation Plan

## Definition
A steel thread is a complete end-to-end implementation with the smallest possible scope that proves the core architecture works. For this project, our steel thread demonstrates: **Command+Command opens an AI assistant that can actually do something on your computer**.

## Steel Thread Scope

### The Core User Journey (90% of the magic)
```
1. User installs extension
2. User hits Command+Command
3. Chat window appears instantly
4. User types: "What's in my package.json?"
5. Assistant reads the file and explains it
6. User hits Escape (conversation saved)
7. User hits Command+Command again (conversation restored)
```

This proves:
- The hotkey binding works
- The chat UI works
- Claude Code SDK integration works
- Real file system access works
- Streaming responses work
- Session persistence works

### What We ARE Building

#### 1. Single Raycast Command
- Command name: `assistant`
- Global hotkey: Command+Command (configurable)
- Mode: `view` (full window)
- Beautiful native Raycast UI

#### 2. Core Chat Interface
```typescript
// Minimal viable UI
- List component for messages
- Search bar as input field
- Streaming message updates
- Loading states
- Error toasts
```

#### 3. Claude Code SDK Integration (Read Only)
```typescript
// The absolute minimum to prove it works
- API key authentication only
- query() with streaming responses
- Read tool only (no Write, Edit, Bash)
- Default model selection
- No permission callbacks (reading is safe)
```

#### 4. Basic Session Management
```typescript
// Simple persistence
- Single session for entire extension
- Save session_id to LocalStorage
- Resume on next launch
- No per-directory sessions yet
```

#### 5. Three Working Examples
To validate the steel thread works:
1. "What files are in this directory?" → Lists files
2. "Read package.json" → Shows file contents
3. "Explain this error: [paste]" → Analyzes and explains

### What We're NOT Building (Yet)

#### Phase 1 Exclusions (Add after steel thread works)
- ❌ File editing/writing capabilities
- ❌ Bash/command execution
- ❌ MCP servers
- ❌ Permission system/trust levels
- ❌ Claude.ai login (API key only for now)
- ❌ Context awareness (current directory, selected files)
- ❌ Smart action pills
- ❌ Per-directory sessions
- ❌ Advanced preferences

#### Phase 2 Exclusions (Much later)
- ❌ Voice input
- ❌ Custom workflows
- ❌ Team sharing
- ❌ Multiple model selection
- ❌ Power user hidden configs

## Technical Implementation

### File Structure
```
claude-raycast/
├── package.json
├── src/
│   ├── assistant.tsx        # The single command
│   └── utils/
│       └── claude.ts         # SDK wrapper
├── assets/
│   └── icon.png
└── README.md
```

### Core Dependencies
```json
{
  "dependencies": {
    "@raycast/api": "^1.64.0",
    "@anthropic-ai/claude-code": "latest",
    "react": "^18.2.0"
  }
}
```

### Minimal Manifest
```json
{
  "$schema": "https://www.raycast.com/schemas/extension.json",
  "name": "ai-assistant",
  "title": "AI Assistant",
  "description": "AI that can actually control your computer",
  "icon": "icon.png",
  "author": "your-name",
  "license": "MIT",
  "commands": [
    {
      "name": "assistant",
      "title": "AI Assistant",
      "subtitle": "Talk to your AI assistant",
      "description": "Opens the AI assistant chat",
      "mode": "view",
      "keywords": ["ai", "chat", "claude"],
      "preferences": [
        {
          "name": "anthropicApiKey",
          "title": "Anthropic API Key",
          "description": "Your Anthropic API key",
          "type": "password",
          "required": true
        }
      ]
    }
  ],
  "preferences": [
    {
      "name": "shortcut",
      "title": "Keyboard Shortcut",
      "description": "Global hotkey to open assistant",
      "type": "textfield",
      "default": "cmd+cmd",
      "required": false
    }
  ]
}
```

### The Entire Implementation (~200 lines)
```typescript
// src/assistant.tsx
import { List, showToast, Toast, LocalStorage, getPreferenceValues } from "@raycast/api";
import { useState, useEffect, useRef } from "react";
import { query } from "@anthropic-ai/claude-code";

interface Preferences {
  anthropicApiKey: string;
}

export default function Assistant() {
  const { anthropicApiKey } = getPreferenceValues<Preferences>();
  const [searchText, setSearchText] = useState("");
  const [messages, setMessages] = useState<Array<{
    id: string;
    role: "user" | "assistant";
    content: string;
  }>>([]);
  const [isLoading, setIsLoading] = useState(false);
  const [sessionId, setSessionId] = useState<string>();
  const streamBuffer = useRef("");

  // Load saved session on mount
  useEffect(() => {
    LocalStorage.getItem<string>("sessionId").then(id => {
      if (id) setSessionId(id);
    });
    LocalStorage.getItem<string>("messages").then(saved => {
      if (saved) setMessages(JSON.parse(saved));
    });
  }, []);

  // Save messages when they change
  useEffect(() => {
    if (messages.length > 0) {
      LocalStorage.setItem("messages", JSON.stringify(messages));
    }
  }, [messages]);

  async function handleSubmit() {
    const text = searchText.trim();
    if (!text || isLoading) return;

    // Add user message
    const userMessage = {
      id: Date.now().toString(),
      role: "user" as const,
      content: text
    };
    setMessages(prev => [...prev, userMessage]);
    setSearchText("");
    setIsLoading(true);
    streamBuffer.current = "";

    try {
      // Create assistant message placeholder
      const assistantId = (Date.now() + 1).toString();
      setMessages(prev => [...prev, {
        id: assistantId,
        role: "assistant",
        content: ""
      }]);

      // Query Claude
      for await (const event of query({
        prompt: text,
        options: {
          includePartialMessages: true,
          resume: sessionId,
          model: "default",
          env: { ANTHROPIC_API_KEY: anthropicApiKey }
        }
      })) {
        // Handle session init
        if (event.type === "system" && event.subtype === "init") {
          setSessionId(event.session_id);
          await LocalStorage.setItem("sessionId", event.session_id);
        }

        // Handle streaming content
        if (event.type === "stream_event" && event.event?.type === "content.delta") {
          const delta = event.event.delta;
          if (delta?.type === "text_delta") {
            streamBuffer.current += delta.text || "";
            setMessages(prev => {
              const updated = [...prev];
              const lastMessage = updated[updated.length - 1];
              if (lastMessage?.role === "assistant") {
                lastMessage.content = streamBuffer.current;
              }
              return updated;
            });
          }
        }
      }
    } catch (error) {
      await showToast({
        style: Toast.Style.Failure,
        title: "Error",
        message: String(error)
      });
    } finally {
      setIsLoading(false);
    }
  }

  return (
    <List
      isLoading={isLoading}
      searchText={searchText}
      onSearchTextChange={setSearchText}
      searchBarPlaceholder="Ask me anything..."
      onSearchBarSubmit={handleSubmit}
    >
      {messages.map(message => (
        <List.Item
          key={message.id}
          title={message.role === "user" ? "You" : "Assistant"}
          subtitle={message.content}
        />
      ))}

      {messages.length === 0 && (
        <List.EmptyView
          title="Start a conversation"
          description="Try: 'What files are in this directory?'"
        />
      )}
    </List>
  );
}
```

## Validation Criteria

### Must Work
1. ✅ **Hotkey**: Command+Command opens the assistant
2. ✅ **Input**: Can type natural language in search bar
3. ✅ **Execution**: Claude reads files when asked
4. ✅ **Display**: Responses stream in real-time
5. ✅ **Persistence**: Conversation survives dismiss/reopen

### Success Metrics
- **Time to first message**: < 2 seconds after hotkey
- **Streaming latency**: < 500ms to first token
- **Read file success rate**: 100% for valid paths
- **Session recovery rate**: 100% on reopen

### Test Scenarios

#### Scenario 1: First Time User
1. Install extension
2. Add API key in preferences
3. Hit Command+Command
4. Type "What files are here?"
5. See list of files
6. ✅ Success: Magic moment achieved

#### Scenario 2: Return User
1. Open assistant
2. Ask "Read package.json"
3. See file contents
4. Hit Escape
5. Hit Command+Command again
6. See previous conversation
7. Continue with "What does the main field do?"
8. Get contextual answer
9. ✅ Success: Persistence works

#### Scenario 3: Error Handling
1. Ask "Read nonexistent.txt"
2. Get friendly error message
3. Ask "What went wrong?"
4. Get helpful explanation
5. ✅ Success: Graceful failure

## Development Steps

### Day 1: Setup (2 hours)
1. Create Raycast extension boilerplate
2. Add Claude Code SDK dependency
3. Configure TypeScript and build
4. Test basic "Hello World" command

### Day 2: Core Implementation (4 hours)
1. Build List-based chat UI
2. Integrate Claude Code SDK
3. Implement streaming responses
4. Add session persistence

### Day 3: Polish & Test (2 hours)
1. Add error handling
2. Improve loading states
3. Test all scenarios
4. Add keyboard shortcut

### Total: 8 hours to working steel thread

## What Success Looks Like

The steel thread is successful when a user can:
1. Install the extension in < 1 minute
2. Open it with Command+Command instantly
3. Ask about files in natural language
4. Get real answers from their actual file system
5. Have their conversation persist between sessions

**This is the foundation.** Once this works flawlessly, we can add:
- Writing/editing files
- Running commands
- Smart permissions
- MCP servers
- Claude.ai login
- All the other magic

But first, we prove the core loop works. No hacks, no shortcuts - just a narrow, well-executed implementation that demonstrates the revolutionary experience of an AI that can actually touch your computer.

## Next Steps After Steel Thread

Once validated, the immediate next priorities are:
1. **Enable Write/Edit** - Let Claude modify files (with preview)
2. **Add Bash** - Let Claude run safe commands
3. **Smart Permissions** - Progressive trust system
4. **Claude.ai Auth** - For Max/Pro users
5. **Context Awareness** - Know current directory

But not until the steel thread is perfect.