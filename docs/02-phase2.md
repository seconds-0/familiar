# Phase 2: Full Implementation Plan

## Executive Summary

Phase 2 transforms the steel thread MVP into the complete AI assistant envisioned in the PRD. Building on the working chat interface with Read-only operations, this phase enables actual computer control through file operations and command execution, implements the progressive trust system, and adds the smart UI features that create the "magic moment" experience.

**Timeline**: 4 weeks (20 development days)
**Goal**: Achieve full PRD functionality with production-ready quality

## Prerequisites

Before starting Phase 2, ensure:
- Steel thread is fully functional (chat, streaming, session persistence)
- Claude Code SDK is properly integrated with TypeScript types
- Basic MCP filesystem server configuration is in place
- Raycast development environment is set up

## Integration Notes (Claude Code SDK + Raycast)

- **Model selection**: Use an explicit model via `options.model` (e.g., `claude-3-opus-20240229`). Consider exposing model choice as a Raycast preference.
- **Built-in tools (exact names)**: `Read`, `Write`, `Edit`, `MultiEdit`, `Bash`, `BashOutput`, `KillShell`, `Grep`, `Glob`, `WebFetch`, `WebSearch`, `Task`, `TodoWrite`, `NotebookEdit`.
- **Trust mapping**: Use `options.allowedTools` for coarse-grained auto-approval per trust level; use `canUseTool(toolName, input)` for contextual prompts/denials.
- **Diff previews**: SDK provides input types (e.g., `EditInput`, `WriteInput`) but not preview generation. Implement your own diff preview and render it in a Detail view.
- **Shell lifecycle**: `BashInput` supports `timeout`/`run_in_background`, but job lifecycle and kill require your own process tracking and a UI affordance that maps to `KillShell` when available.
- **MCP servers**: Prefer `npx -y @modelcontextprotocol/server-filesystem` for portability; set `type: "stdio"` explicitly. Use SSE/HTTP configs where appropriate.
- **Raycast UI**: For large content (diffs, logs), render markdown in `List.Item.Detail`. Keep `subtitle` short.

## Implementation Stages

### Stage 1: Enable File Operations (2 days)

#### Goal
Allow Claude to write, edit, and create files with user approval and preview capabilities.

#### Features to Implement
1. **Write/Edit Tool Enablement**
   - Enable Write, Edit, and MultiEdit tools in the canUseTool handler
   - Implement diff generation for previews
   - Add syntax-aware file change previews

2. **Preview UI Components**
   - Diff viewer using Raycast's Detail component
   - Syntax highlighting via markdown code blocks
   - Before/after comparison views

3. **Confirmation Dialogs**
   - Use `confirmAlert` for file operations (Raycast API lines 704-722)
   - Show file path, operation type, and preview
   - Include "Apply to All" option for batch operations

#### Implementation Details

```typescript
// src/utils/permissions.ts
async function handleFileOperation(
  toolName: string,
  input: EditInput | WriteInput
): Promise<PermissionResult> {
  // Generate app-owned diff preview (SDK provides input types only)
  const preview = await generateDiffPreview(input);

  // Show confirmation with Raycast's confirmAlert
  const confirmed = await confirmAlert({
    title: `${toolName} ${input.file_path}?`,
    message: preview,
    icon: Icon.Document,
    primaryAction: {
      title: "Apply Changes",
      style: Alert.ActionStyle.Default
    }
  });

  return confirmed
    ? { behavior: "allow", updatedInput: input }
    : { behavior: "deny", message: "User skipped" };
}
```

#### Testing Requirements
- Create new files in empty directories
- Edit existing files with multi-line changes
- Test MultiEdit with 5+ simultaneous edits
- Verify preview accuracy for different file types
- Test cancellation mid-operation

#### UX Considerations
- Preview should show max 20 lines of context
- Use color coding: green for additions, red for deletions
- Show file type icon based on extension
- Include file size warning for large files (>1MB)

#### Tradeoffs
- **Preview Generation**: Adds 100-200ms latency but ensures user confidence
- **Confirmation Fatigue**: Every operation requires approval initially (addressed in Stage 3)
- **Diff Complexity**: Simple line-based diffs may miss semantic changes

---

### Stage 2: Command Execution with Safety (2 days)

#### Goal
Enable Bash command execution with intelligent safety detection and streaming output.

#### Features to Implement
1. **Command Safety Classification**
   - Safe commands whitelist (auto-approved)
   - Dangerous commands blacklist (always blocked)
   - Unknown commands (require confirmation)

2. **Streaming Output Display**
   - Real-time output in Detail markdown (List.Item.Detail)
   - Accessories show compact status only (e.g., spinner, elapsed time)
   - Background process management with a visible "Stop"/kill control

3. **Command Intelligence**
   - Detect command intent (read vs write vs system)
   - Parse command arguments for safety analysis
   - Support command chaining with && and ||

#### Implementation Details

```typescript
// src/utils/commands.ts
const SAFE_COMMANDS = [
  'ls', 'pwd', 'echo', 'cat', 'grep', 'find',
  'git status', 'git diff', 'git log',
  'npm list', 'npm test', 'yarn test',
  'python --version', 'node --version'
];

const DANGEROUS_PATTERNS = [
  /rm\s+-rf/, /sudo/, /chmod\s+777/,
  /curl.*\|\s*sh/, />\/dev\/sda/
];

function classifyCommand(command: string): CommandSafety {
  // Check against patterns using SDK's BashInput type
  // (SDK docs lines 413-417)
  if (DANGEROUS_PATTERNS.some(p => p.test(command))) {
    return CommandSafety.Dangerous;
  }
  if (SAFE_COMMANDS.some(s => command.startsWith(s))) {
    return CommandSafety.Safe;
  }
  return CommandSafety.Unknown;
}
```

#### Testing Requirements
- Execute safe commands without prompts
- Block dangerous commands with clear explanation
- Test command timeout handling (max 120 seconds)
- Verify streaming output for slow commands
- Test background process lifecycle

#### UX Considerations
 - Show spinner for running commands
- Display elapsed time for long operations
- Truncate output at 1000 lines with "Show More" option
- Color code output: stdout (white), stderr (yellow)

#### Tradeoffs
- **Safety vs Convenience**: Conservative defaults mean more confirmations
- **Output Buffering**: Real-time streaming vs batched updates
- **Process Management**: Background processes need careful cleanup

---

### Stage 3: Progressive Trust System (3 days)

#### Goal
Build user confidence through graduated permissions that reduce friction over time.

#### Trust Levels
1. **Untrusted (0)**: All operations require confirmation
2. **Minimal (1-2)**: Read operations auto-approved
3. **Moderate (3-4)**: Safe edits auto-approved
4. **High (5-9)**: Most operations auto-approved
5. **Full (10+)**: Only dangerous operations need confirmation

#### Features to Implement
1. **Trust Tracking**
   - Per-directory trust levels
   - Success/failure counting
   - Trust decay over time (30 days)

2. **Visual Indicators**
   - Trust badge in navigation title
   - Color-coded operation indicators
   - Progress toward next trust level

3. **Smart Defaults**
   - Different thresholds for different operations
   - Context-aware trust (e.g., test files = lower risk)
   - Trust inheritance for subdirectories
4. **Tool Gating Integration**
   - Map trust levels to `options.allowedTools` for auto-approval
   - Use `canUseTool` for contextual prompts/denials per operation

#### Implementation Details

```typescript
// src/utils/trust.ts
interface TrustPolicy {
  level: TrustLevel;
  allowedTools: string[];
  requireConfirmation: string[];
  autoApprove: string[];
}

async function evaluateTrust(
  operation: string,
  context: OperationContext
): Promise<boolean> {
  const trustLevel = await getTrustLevel(context.directory);
  const policy = getTrustPolicy(trustLevel);

  // Auto-approve if in allowlist
  if (policy.autoApprove.includes(operation)) {
    return true;
  }

  // Check context-specific rules
  if (context.isTestFile && operation === "Edit") {
    return trustLevel >= TrustLevel.Minimal;
  }

  return false;
}
```

#### Testing Requirements
- Verify trust increments after successful operations
- Test trust level persistence across sessions
- Verify auto-approval at each level
- Test trust decay after 30 days
- Verify dangerous operations always prompt

#### UX Considerations
- Show toast notification at trust milestones (Raycast API lines 674-699)
- Display trust level in status bar: "Trust: ●●●○○"
- Provide trust explanation on hover
- Allow manual trust reset in preferences

#### Tradeoffs
- **Per-Directory Trust**: More secure but requires rebuilding trust
- **Decay Rate**: Balance security vs user annoyance
- **Threshold Tuning**: Too low = risky, too high = frustrating

---

### Stage 4: MCP Server Integration (2 days)

#### Goal
Enable extended capabilities through Model Context Protocol servers.

#### Features to Implement
1. **Auto-Configuration**
   - Detect project type from file markers
   - Configure appropriate servers automatically
   - Handle missing dependencies gracefully

2. **Server Types**
   - **filesystem**: Always enabled, scoped to cwd (SDK docs lines 173-189)
   - **nodejs**: For JavaScript/TypeScript projects
   - **python**: For Python projects
   - **git**: For version-controlled projects
   - **search**: If API keys available (SDK docs lines 193-204)

3. **Lifecycle Management**
   - Lazy server initialization
   - Health checking and restart
   - Clean shutdown on exit

#### Implementation Details

```typescript
// src/utils/mcp.ts - Enhanced from integration guide
async function detectAndConfigureMCP(
  workingDir: string
): Promise<MCPServers> {
  const servers: MCPServers = {};

  // Always enable filesystem (stdio type)
  servers.filesystem = {
    command: "npx",
    args: ["-y", "@modelcontextprotocol/server-filesystem"],
    env: { ALLOWED_PATHS: workingDir }
  };

  // Project-specific servers
  if (await exists(join(workingDir, "package.json"))) {
    servers.nodejs = {
      command: "npx",
      args: ["-y", "@modelcontextprotocol/server-nodejs"]
    };
  }

  // API-based servers (SSE type)
  if (process.env.BRAVE_API_KEY) {
    servers.search = {
      type: "sse",
      url: "https://api.search.brave.com/mcp/sse",
      headers: { "X-API-KEY": process.env.BRAVE_API_KEY }
    };
  }

  return servers;
}
```

#### Testing Requirements
- Test auto-detection in Node, Python, and plain projects
- Verify server startup error handling
- Test server crash recovery
- Verify tool availability in Claude
- Test cleanup on extension close

#### UX Considerations
- Show available MCP servers in UI
- Indicate server health with status icons
- Provide manual server management in advanced settings
- Show helpful errors if servers fail to start

#### Tradeoffs
- **Process Overhead**: Each stdio server is a separate process
- **Dependency Management**: Requires npx and internet for first run
- **Error Recovery**: Balance retry attempts vs giving up

---

### Stage 5: Smart Context & Suggestions (2 days)

#### Goal
Make the assistant contextually aware and proactively helpful.

#### Features to Implement
1. **Context Detection**
   - Current working directory
   - Selected Finder items (Raycast API line 738)
   - Note: Recent terminal commands and open IDE files are not available via Raycast APIs (future/out-of-scope)

2. **Smart Suggestions**
   - Analyze conversation for next actions
   - Provide contextual action pills
   - Learn from user patterns

3. **Action Pills**
   - After errors: [Fix This] [Debug] [Explain]
   - After file operations: [Open] [Edit] [Run Tests]
   - After explanations: [Show Example] [Try It]

#### Implementation Details

```typescript
// src/utils/suggestions.ts
async function generateSuggestions(
  lastMessage: Message,
  context: AppContext
): Promise<Suggestion[]> {
  const suggestions: Suggestion[] = [];

  // Error context
  if (lastMessage.content.match(/error|failed|exception/i)) {
    suggestions.push({
      title: "Fix this error",
      action: () => sendMessage("Fix the error above"),
      icon: Icon.Bug
    });
  }

  // File context from Finder
  const selectedFiles = await getSelectedFinderItems();
  if (selectedFiles.length > 0) {
    suggestions.push({
      title: `Analyze ${selectedFiles[0].name}`,
      action: () => sendMessage(`Explain ${selectedFiles[0].path}`),
      icon: Icon.Document
    });
  }

  // Git context
  if (await exists(join(context.cwd, ".git"))) {
    suggestions.push({
      title: "Show changes",
      action: () => sendMessage("What are my uncommitted changes?"),
      icon: Icon.Branch
    });
  }

  return suggestions;
}
```

#### Testing Requirements
- Test context detection in various scenarios
- Verify suggestions appear appropriately
- Test Finder selection integration
- Verify context doesn't override explicit requests
- Test suggestion learning over time

#### UX Considerations
- Show max 3 suggestions to avoid clutter
- Use keyboard shortcuts for quick access (1, 2, 3)
- Fade in suggestions after 500ms delay
- Allow dismissing suggestions with Escape

#### Tradeoffs
- **Context Overhead**: Gathering context adds latency
- **Suggestion Relevance**: Too many = noise, too few = not helpful
- **Privacy**: Context gathering must respect user boundaries

---

### Stage 6: Enhanced UI & Rendering (3 days)

#### Goal
Provide rich, beautiful content display that makes information immediately useful.

#### Features to Implement
1. **Rich Content Rendering**
   - Syntax-highlighted code blocks
   - Inline image display
   - Markdown tables and lists
   - Chart/graph visualization

2. **Message Formatting**
   - Tool use indicators with icons
   - Timestamp and duration display
   - Collapsible long responses
   - Copy button for code blocks

3. **File Previews**
   - Inline file content display
   - Side-by-side diff views
   - Image thumbnails
   - CSV/JSON table rendering

#### Implementation Details

```typescript
// src/components/MessageRenderer.tsx
function MessageRenderer({ message }: { message: Message }) {
  // Parse content for rich elements
  const blocks = parseMessageContent(message.content);

  return (
    <List.Item
      title={message.role === "user" ? "You" : "Assistant"}
      detail={
        <List.Item.Detail
          markdown={renderMarkdown(blocks)}
          metadata={
            <List.Item.Detail.Metadata>
              {message.toolUses?.map(tool => (
                <List.Item.Detail.Metadata.Label
                  key={tool.id}
                  title={tool.toolName}
                  icon={getToolIcon(tool.toolName)}
                />
              ))}
              <List.Item.Detail.Metadata.Separator />
              <List.Item.Detail.Metadata.Label
                title="Duration"
                text={formatDuration(message.duration)}
              />
            </List.Item.Detail.Metadata>
          }
        />
      }
    />
  );
}
```

#### Testing Requirements
- Test rendering of various code languages
- Verify image display (local and remote)
- Test markdown edge cases (nested lists, tables)
- Verify performance with 100+ messages
- Test copy functionality for code blocks

#### UX Considerations
- Limit code blocks to 50 lines with "Show More"
- Use consistent syntax highlighting theme
- Lazy load images to improve performance
- Provide fallback for unsupported content

#### Tradeoffs
- **Rendering Performance**: Rich content vs speed
- **Memory Usage**: Caching vs re-rendering
- **Visual Density**: Information vs whitespace

---

### Stage 7: Claude.ai Authentication (2 days)

#### Goal
Enable seamless authentication for Claude.ai Max/Pro users.

#### Features to Implement
1. **OAuth Flow**
   - Detect missing authentication
   - Trigger Claude.ai login automatically
   - Handle token refresh

2. **Dual Auth Support**
   - Prefer API key in Raycast (stable, explicit)
   - Optionally detect Claude.ai auth if SDK supports non-interactive flow
   - Allow manual switching

3. **Session Management**
   - Persist auth tokens securely
   - Handle expiration gracefully
   - Clear credentials on logout

#### Implementation Details

```typescript
// src/utils/auth.ts
async function authenticate(): Promise<AuthConfig> {
  const prefs = getPreferenceValues<Preferences>();

  // Try Claude.ai first (auto-handled by SDK)
  try {
    const testQuery = query({
      prompt: "test",
      options: { maxTokens: 1 }
    });

    // If this succeeds, Claude.ai auth worked
    for await (const _ of testQuery) {
      break;
    }

    return { type: "claudeai" };
  } catch (error) {
    // Fallback to API key
    if (prefs.anthropicApiKey) {
      return {
        type: "apikey",
        env: { ANTHROPIC_API_KEY: prefs.anthropicApiKey }
      };
    }

    throw new Error("Authentication required");
  }
}
```

#### Testing Requirements
- Test fresh install authentication flow
- Verify token refresh handling
- Test fallback from Claude.ai to API key
- Test explicit auth method switching
- Verify secure credential storage

#### UX Considerations
- Show auth status in navigation title
- Provide clear error messages for auth failures
- One-click re-authentication from error toast
- Show auth method in preferences

#### Tradeoffs
- **Complexity**: Dual auth adds code complexity
- **User Confusion**: Which method to choose?
- **Token Management**: Refresh vs re-login

---

### Stage 8: Advanced Features & Polish (3 days)

#### Goal
Add power user features and polish for store submission.

#### Features to Implement
1. **Hidden Power Features**
   - File-based permission rules (SDK docs lines 129-149)
   - Custom MCP server configuration
   - Advanced keyboard shortcuts
   - Workflow templates

2. **Performance Optimization**
   - Message virtualization for long conversations
   - Intelligent caching strategies
   - Debounced operations
   - Lazy loading

3. **Polish & Refinement**
   - Onboarding experience
   - Error message improvements
   - Loading state refinements
   - Icon and branding

#### Implementation Details

```typescript
// Persist settings via Raycast LocalStorage (conceptual schema)
{
  "permissions": {
    "allow": [
      "Read(**/*.md)",
      "Bash(npm run lint)",
      "Edit(src/**/*.ts)"
    ],
    "deny": [
      "Read(.env*)",
      "Write(production/**)",
      "Bash(rm -rf *)"
    ],
    "ask": [
      "Bash(git push*)",
      "WebFetch"
    ]
  },
  "mcpServers": {
    "custom": {
      "command": "my-custom-server",
      "args": ["--production"]
    }
  }
}
```

#### Testing Requirements
- Load test with 500+ messages
- Test hidden settings discovery flow
- Verify keyboard shortcuts globally
- Test onboarding for new users
- Performance profiling

#### UX Considerations
- Hidden features should be discoverable through exploration
- Onboarding should take < 30 seconds
- Performance should not degrade with history
- Polish should feel "Apple-like"

#### Tradeoffs
- **Feature Discovery**: Hidden vs documented
- **Performance**: Features vs speed
- **Onboarding**: Completeness vs brevity

---

## Testing Strategy

### Unit Testing
```typescript
// src/__tests__/permissions.test.ts
describe('Permission Handler', () => {
  it('should auto-approve safe operations');
  it('should block dangerous commands');
  it('should increment trust on success');
  it('should generate accurate previews');
});
```

### Integration Testing
```typescript
// src/__tests__/integration.test.ts
describe('End-to-End Flows', () => {
  it('should complete "fix build" workflow');
  it('should handle multi-file refactoring');
  it('should persist sessions correctly');
  it('should recover from errors gracefully');
});
```

### User Acceptance Testing
1. **Developer Workflow**: Fix build errors → run tests → commit
2. **PM Workflow**: Summarize changes → generate release notes
3. **Designer Workflow**: Batch process images → organize files
4. **Power User**: Complex refactoring with custom MCP servers

---

## Success Metrics

### Performance Targets
- **First Token Latency**: < 500ms
- **UI Response Time**: < 100ms
- **Session Load Time**: < 200ms
- **MCP Server Start**: < 2 seconds

### User Experience Metrics
- **Trust Achievement**: 60% reach "High" trust in first week
- **Zero Config Success**: 90% never open preferences
- **Dangerous Block Rate**: 100% of rm -rf commands blocked
- **Completion Rate**: 80% of started tasks completed

### Quality Metrics
- **Test Coverage**: > 80%
- **Error Recovery Rate**: 95% of errors handled gracefully
- **Session Recovery**: 100% of sessions recoverable
- **Memory Leaks**: 0 after 8-hour usage

---

## Risk Analysis & Mitigation

### Technical Risks

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| MCP server crashes | High | Medium | Implement health checks and auto-restart |
| Memory leaks with streaming | High | Low | Use proper cleanup and weak references |
| File operation corruption | Critical | Low | Always create backups before editing |
| Auth token expiration | Medium | Medium | Implement refresh with retry logic |

### User Experience Risks

| Risk | Impact | Likelihood | Mitigation |
|------|--------|------------|------------|
| Confirmation fatigue | High | High | Progressive trust system reduces over time |
| Dangerous command execution | Critical | Low | Multi-layer safety checks |
| Lost conversations | Medium | Low | Aggressive session persistence |
| Slow performance | High | Medium | Virtualization and lazy loading |

---

## Implementation Timeline

### Week 1: Foundation (Days 1-5)
- **Monday-Tuesday**: Stage 1 - File Operations
- **Wednesday-Thursday**: Stage 2 - Command Execution
- **Friday**: Integration testing and bug fixes

### Week 2: Trust & Intelligence (Days 6-10)
- **Monday-Wednesday**: Stage 3 - Progressive Trust System
- **Thursday-Friday**: Stage 4 - MCP Server Integration

### Week 3: User Experience (Days 11-15)
- **Monday-Tuesday**: Stage 5 - Smart Context & Suggestions
- **Wednesday-Friday**: Stage 6 - Enhanced UI & Rendering

### Week 4: Polish & Launch (Days 16-20)
- **Monday-Tuesday**: Stage 7 - Claude.ai Authentication
- **Wednesday-Thursday**: Stage 8 - Advanced Features
- **Friday**: Final testing and store submission prep

---

## Post-Launch Roadmap

### Phase 3 Possibilities (Future)
- Voice input and control
- Multi-modal support (screenshots, diagrams)
- Team collaboration features
- Custom workflow marketplace
- IDE extensions integration
- Mobile companion app

### Success Indicators
- 1000+ weekly active users in first month
- 4.5+ star rating in Raycast Store
- Featured in Raycast newsletter
- Community-contributed MCP servers

---

## Conclusion

Phase 2 transforms the steel thread MVP into a production-ready AI assistant that fulfills the PRD vision. By implementing these stages methodically, we create an experience that feels magical while maintaining safety and reliability. The progressive trust system ensures users feel in control while reducing friction over time. The smart context and rich UI make the assistant feel like a natural extension of the user's workflow.

The key to success is balancing power with safety, automation with control, and features with performance. Each stage builds on the previous, creating a cohesive experience that delights users from their first interaction through becoming power users.

With careful implementation of this plan, we'll deliver an AI assistant that truly can control your computer - safely, intelligently, and delightfully.