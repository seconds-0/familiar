# Magical Agent Visualization System
> Transforming Claude Code's autonomous orchestration into an enchanting, transparent experience

## Concept Overview

### The Magical Assistant Metaphor

The Familiar app currently presents Claude Code as a single, monolithic assistant. But behind the scenes, Claude Code operates more like a master wizard coordinating specialized familiars—each agent has distinct magical abilities and focuses on specific aspects of complex requests. This hidden orchestration represents a missed opportunity for user understanding and engagement.

**Vision**: Transform the invisible agent orchestration into an enchanting, transparent experience where users witness their AI Familiar casting spells (tool calls) and summoning specialized beings (subagents) to accomplish complex tasks.

### User Mental Model Transformation

**Current Experience**:
- User asks question → Black box thinking → Answer appears
- No visibility into magical process complexity or parallel spell work
- Single progress indicator for all mystical activity

**Magical Experience**:
- User asks question → Familiar starts glowing with magical intent
- Specialized agents materialize with spell-casting animations and unique magical icons
- Real-time status updates with contextual, mystical summaries
- Visual hierarchy showing how complex requests are decomposed through magical delegation
- Completion sparkles and enchanting transitions to resolved state

### Core Principles

1. **Autonomous Wonder**: Agents spawn automatically based on Familiar's magical decision-making, not user control
2. **Transparent Mystery**: Complex magical processes become visible but retain sense of enchanted capability
3. **Functional Magic**: Animations and effects serve understanding while delighting the user
4. **Performance Respect**: Magical elements gracefully degrade and respect accessibility preferences
5. **Optional Enchantment**: Advanced magical visualizations can be disabled for minimal UI mode

## Visual Design System

### Right Sidebar Architecture

The current Familiar window (720x460 fixed) expands to accommodate a resizable right sidebar for agent visualization:

```
┌─────────────────────┐ ├── ┌─────────────────┐
│                     │ │   │ 🧙‍♂️ Main Claude   │
│   Current Content   │ │   │   ✨ Thinking... │
│   • Prompt field    │ │   ├─────────────────┤
│   • Transcript      │ │   │ 🔍 Searching...  │
│   • Tool summaries  │ │   │   patterns in    │
│   • Usage info      │ │   │   codebase       │
│                     │ │   ├─────────────────┤
│                     │ │   │ 🏗️ Planning...   │
│                     │ │   │   architecture   │
│                     │ │   │   refactor       │
└─────────────────────┘ │   └─────────────────┘
    Main Content        │     Agent Sidebar
    (min 500px)         │     (200-400px)
```

### Spell Icon System

Each agent type gets a distinctive magical icon with enchanting animation states:

#### **🔍 Code Search Specialist**
- **Icon**: Magnifying glass with sparkles
- **Spawning**: Glass materializes with light refraction effect (0.8s)
- **Working**: Sparkles orbit the lens, searching beam sweeps
- **Complete**: Bright flash as findings are discovered

#### **🏗️ Engineering Manager**
- **Icon**: Blueprint scroll with floating gears
- **Spawning**: Scroll unfurls with architectural symbols appearing (0.5s)
- **Working**: Gears rotate, blueprint glows with planning activity
- **Complete**: Gears align with satisfying click, scroll rolls up

#### **✨ General Purpose**
- **Icon**: Multi-colored swirling energy orb
- **Spawning**: Energy coalesces from scattered particles (0.6s)
- **Working**: Colors shift and pulse with task complexity
- **Complete**: Orb crystallizes into gem-like clarity

#### **⚡ Background Processes**
- **Icon**: Lightning bolt for shell commands
- **Spawning**: Electric arc forms between connection points (0.4s)
- **Working**: Continuous electrical animation with crackling
- **Complete**: Lightning settles into stable power symbol

#### **🎯 Task Orchestrator**
- **Icon**: Conductor's baton with musical notes
- **Spawning**: Baton appears with a flourish of musical symbols (0.7s)
- **Working**: Notes dance around baton as tasks are coordinated
- **Complete**: Final chord visualization with harmony lines

### Status Color Language

**Spawning State** (Cornflower Blue `#6495ED`)
- Gentle blue glow during magical initialization
- Particle effects as agent materializes
- Transition duration: 0.8 seconds

**Active Working** (Golden Amber `#FFB000`)
- Warm, pulsing glow indicating productive spell activity
- Breath-like rhythm: 2-second inhale/exhale cycle
- Intensity varies with magical processing complexity

**Waiting/Blocked** (Soft Purple `#9370DB`)
- Cooler tone indicating dependency wait for other spells
- Slower, more subtle pulsing pattern
- Gentle reminder without urgency

**Success Complete** (Forest Green `#228B22`)
- Bright flash transitioning to steady checkmark
- Sparkle particle burst on spell completion
- Fades to subtle green outline for magical history

**Error/Blocked** (Warning Red `#DC143C`)
- Attention-getting pulse with warning symbol
- Distinct from active working through urgency pattern
- Clear visual hierarchy for spell resolution needs

### Agent Interaction States

#### **Compact Mode** (Default)
```
🔍 Seeking patterns        [2m ago]
🏗️ Weaving structure      [active]
⚡ Testing spells          [waiting]
```

#### **Expanded Mode** (On Click)
```
🔍 Code Search Specialist             [2m ago]
├─ Searched 247 files for "auth"
├─ Found 15 implementation patterns
├─ Analyzed dependency relationships
└─ ✅ Generated pattern summary

🏗️ Engineering Manager                [active]
├─ 📋 Breaking down user requirements
├─ 🎯 Currently: Evaluating architecture options
├─ ⏱️ Estimated completion: ~3 minutes
└─ 🔗 Waiting for: Search results analysis
```

### Magical Action Bar Integration

Following Claude Code's current pattern, Familiar displays a **magical action bar** at the bottom of the main content area showing real-time spell activities:

#### **Action Bar Examples**:
```
🔍 Searching through authentication patterns in 247 files...

✨ Analyzing code structure and dependencies...

🏗️ Planning refactor approach for auth system...

⚡ Running npm test -- checking 15 test suites...

🎯 Coordinating file edits across 8 components...
```

#### **Action Bar Behavior**:
- **Real-time updates**: Shows current primary action from most active agent
- **Contextual verbs**: Uses magical language ("weaving", "conjuring", "divining")
- **Progress indication**: Optional progress bar for determinate operations
- **Clickable**: Clicking focuses the sidebar on the active agent
- **Dismissible**: Users can hide the action bar for minimal UI mode

#### **Integration with Sidebar**:
- Action bar shows **primary spell** in progress
- Sidebar shows **all active spells** with hierarchy
- Clicking action bar highlights corresponding agent in sidebar
- Completed spells briefly flash in action bar before next spell takes over

## Status Summary System

### Cheap LLM Integration

Generate contextual, human-readable status summaries using Haiku-3.5 for cost-effective real-time updates:

**API Call Structure**:
```python
def generate_agent_summary(agent_type: str, current_task: str, context: dict) -> str:
    prompt = f"""
    Generate a 1-3 word status for this AI agent:
    Type: {agent_type}
    Task: {current_task}
    Context: {context}

    Examples:
    - "Searching files" → "Finding patterns"
    - "Running tests" → "Validating code"
    - "Planning refactor" → "Designing structure"

    Keep it magical but informative:
    """
    return haiku_client.generate(prompt, max_tokens=10)
```

**Cost Analysis**: ~$0.0001 per summary (Haiku-3.5 pricing), sustainable for real-time updates.

### Context-Aware Examples

| Agent Activity | Raw Technical Status | Magical Summary |
|---------------|---------------------|-----------------|
| File search with regex patterns | `grep -r "authentication" --include="*.ts"` | `🔍 Seeking auth secrets` |
| Test execution in background | `npm test -- --coverage --reporter=json` | `⚡ Validating changes` |
| Planning architecture changes | `Analyzing dependencies for refactor` | `🏗️ Designing structure` |
| Code analysis and review | `Reading 15 files, extracting patterns` | `✨ Understanding codebase` |
| Permission system evaluation | `Checking file access permissions` | `🛡️ Verifying safety` |

## Technical Architecture

### Backend Extensions

#### New SSE Event Types

```python
# claude_service.py - New event types for agent visualization

@dataclass
class AgentSpawnedEvent:
    agent_id: str
    parent_id: str | None
    agent_type: str  # "code-search-specialist", "engineering-manager", etc.
    goal: str
    estimated_duration: int | None
    spawn_timestamp: datetime

@dataclass
class AgentProgressEvent:
    agent_id: str
    status: str  # "initializing", "working", "waiting", "completing"
    progress_summary: str  # Generated by Haiku
    current_task: str
    resources_used: dict[str, Any]  # CPU, memory, tool calls

@dataclass
class AgentCompletedEvent:
    agent_id: str
    final_status: str  # "success", "error", "cancelled"
    execution_time: float
    results_summary: str
    output_artifacts: list[str]  # Files created, commands run, etc.
```

#### Enhanced ClaudeSession Architecture

```python
class ClaudeSession:
    def __init__(self):
        # Existing code...
        self._active_agents: dict[str, AgentContext] = {}
        self._agent_hierarchy: dict[str, list[str]] = {}  # parent_id -> child_ids
        self._status_summarizer = HaikuSummarizer()

    @dataclass
    class AgentContext:
        agent_id: str
        parent_id: str | None
        agent_type: str
        goal: str
        status: AgentStatus
        spawn_time: datetime
        last_update: datetime
        tools_used: list[str]
        progress_messages: list[str]
        resource_usage: ResourceMetrics

    async def _track_agent_lifecycle(self, agent_event: dict[str, Any]) -> None:
        """Monitor SDK agent events and emit UI-friendly events"""
        if agent_event.get("type") == "agent_spawned":
            await self._handle_agent_spawn(agent_event)
        elif agent_event.get("type") == "agent_progress":
            await self._handle_agent_progress(agent_event)
        elif agent_event.get("type") == "agent_completed":
            await self._handle_agent_completion(agent_event)

    async def _generate_status_summary(self, agent: AgentContext) -> str:
        """Generate human-readable status using Haiku"""
        context = {
            "type": agent.agent_type,
            "current_task": agent.progress_messages[-1] if agent.progress_messages else agent.goal,
            "tools_used": agent.tools_used,
            "duration": (datetime.now() - agent.spawn_time).total_seconds()
        }
        return await self._status_summarizer.generate_summary(context)
```

### Frontend Components

#### Core SwiftUI Architecture

```swift
// New layout structure for agent sidebar
struct FamiliarView: View {
    @StateObject private var viewModel = FamiliarViewModel()
    @StateObject private var agentManager = AgentVisualizationManager()
    @State private var sidebarWidth: CGFloat = 280

    var body: some View {
        HSplitView {
            // Main content area (existing layout)
            VStack(alignment: .leading, spacing: 16) {
                // Current UI components...
            }
            .frame(minWidth: 500)

            // Agent visualization sidebar
            AgentSidebarView(manager: agentManager)
                .frame(width: sidebarWidth)
                .frame(minWidth: 200, maxWidth: 400)
        }
        .frame(width: 720 + sidebarWidth, height: 460)
    }
}
```

#### Agent Sidebar Components

```swift
struct AgentSidebarView: View {
    @ObservedObject var manager: AgentVisualizationManager
    @State private var expandedAgents: Set<String> = []

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header with collapse/expand controls
            AgentSidebarHeader(
                agentCount: manager.activeAgents.count,
                isCollapsed: $manager.isCollapsed
            )

            // Scrollable agent tree
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(manager.rootAgents, id: \.id) { agent in
                        AgentTreeItemView(
                            agent: agent,
                            children: manager.childAgents(of: agent.id),
                            isExpanded: expandedAgents.contains(agent.id),
                            onToggle: { toggleExpanded(agent.id) }
                        )
                    }
                }
                .padding(.horizontal, 12)
            }
        }
        .background(Color(NSColor.controlBackgroundColor))
    }
}
```

#### Magical Animation System

```swift
struct SpellEffectView: View {
    let agentType: AgentType
    let animationState: AgentAnimationState

    var body: some View {
        ZStack {
            // Base icon
            AgentIconView(type: agentType)

            // Magical particle effects
            if animationState == .spawning {
                ParticleSystemView(
                    system: .burst,
                    colors: agentType.particleColors,
                    count: 20,
                    duration: 0.8
                )
            }

            // Working state animations
            if animationState == .working {
                PulsingGlowView(
                    color: agentType.workingColor,
                    intensity: 0.3,
                    period: 2.0
                )
            }
        }
    }
}

// High-performance particle system using Canvas
struct ParticleSystemView: View {
    let system: ParticleEffect
    let colors: [Color]
    let count: Int
    let duration: Double

    @State private var particles: [Particle] = []
    @State private var animationTime: Double = 0

    var body: some View {
        Canvas { context, size in
            for particle in particles {
                let progress = animationTime / duration
                let position = particle.position(at: progress, in: size)
                let opacity = particle.opacity(at: progress)

                context.fill(
                    Path(ellipseIn: CGRect(
                        origin: position,
                        size: CGSize(width: 4, height: 4)
                    )),
                    with: .color(particle.color.opacity(opacity))
                )
            }
        }
        .onAppear { generateParticles() }
        .onReceive(Timer.publish(every: 0.016, on: .main, in: .common).autoconnect()) { _ in
            animationTime += 0.016
        }
    }
}
```

## User Experience Flow

### Typical Interaction Sequence

1. **Initial Query Submission**
   ```
   User: "Help me refactor the authentication system"

   UI Response:
   - Main Claude icon starts gentle blue glow (thinking)
   - Sidebar remains empty initially
   ```

2. **Agent Orchestration Begins**
   ```
   Claude Code Decision: Spawn code-search-specialist + engineering-manager

   UI Response:
   - 🔍 materializes with sparkle burst (0.8s animation)
   - 🏗️ unfurls with blueprint effect (0.5s delay)
   - Status: "🔍 Seeking patterns" / "🏗️ Analyzing scope"
   ```

3. **Parallel Agent Activity**
   ```
   Search Agent: Scanning codebase
   Planning Agent: Waiting for search results

   UI Response:
   - Search agent: Golden pulsing with orbital sparkles
   - Planning agent: Purple waiting state with slower pulse
   - Live status updates every 2-3 seconds
   ```

4. **Sub-Agent Spawning**
   ```
   Engineering Manager spawns: security-specialist + performance-analyst

   UI Response:
   - Hierarchy lines connect to show parent/child relationship
   - New agents appear with connection animations
   - Tree structure reorganizes smoothly
   ```

5. **Completion and Results**
   ```
   All agents complete their specialized tasks

   UI Response:
   - Green checkmark sparkles for each completion
   - Final results compiled by main Claude
   - Gentle fade to history state
   - Main transcript updated with synthesized results
   ```

### Interactive Behaviors

**Agent Click Actions**:
- **Single tap**: Toggle expanded/compact view for details
- **Double tap**: Focus main transcript on agent's contributions
- **Right-click**: Context menu with options:
  - "Show execution log"
  - "Copy agent output"
  - "Hide completed agents"

**Sidebar Behaviors**:
- **Drag edge**: Resize sidebar width (200-400px range)
- **Collapse button**: Minimize to icon-only mode
- **Clear history**: Remove completed agents from view
- **Export logs**: Save agent execution timeline

## Implementation Phases

### Phase 1: Foundation (Week 1-2)
**Goal**: Basic sidebar infrastructure without animations

**Tasks**:
- [ ] Extend Familiar window layout to HSplitView architecture
- [ ] Create AgentSidebarView with static agent list
- [ ] Add basic AgentVisualizationManager for state management
- [ ] Implement simple agent icon display (no animations)
- [ ] Add mock agent data for UI development

**Acceptance Criteria**:
- Sidebar appears and resizes properly
- Static agent list displays with correct icons
- No performance impact on main UI
- Graceful fallback if sidebar is disabled

### Phase 2: Agent Lifecycle Events (Week 3-4)
**Goal**: Real-time agent tracking from Claude Code SDK

**Tasks**:
- [ ] Extend ClaudeSession with agent lifecycle monitoring
- [ ] Add new SSE event types: agent_spawned, agent_progress, agent_completed
- [ ] Implement AgentContext tracking in backend
- [ ] Connect frontend to real agent events via SSE stream
- [ ] Add basic status text updates (no summaries yet)

**Acceptance Criteria**:
- Agents appear in real-time as Claude Code spawns them
- Status updates reflect actual agent activity
- Hierarchy relationships display correctly
- Error handling for malformed agent events

### Phase 3: Magical Animations (Week 5-6)
**Goal**: Delightful spawn/completion effects

**Tasks**:
- [ ] Implement ParticleSystemView with Canvas for performance
- [ ] Create SpellEffectView for agent-specific animations
- [ ] Add spawn burst effects for agent materialization
- [ ] Implement working state animations (pulsing, rotation)
- [ ] Create completion sparkle effects
- [ ] Add accessibility support with prefersReducedMotion

**Acceptance Criteria**:
- Smooth 60fps animations on typical hardware
- Graceful degradation for reduced motion preferences
- No animation interference with text readability
- Battery-conscious particle counts

### Phase 4: Status Summarization (Week 7-8)
**Goal**: Human-readable agent descriptions

**Tasks**:
- [ ] Integrate Haiku-3.5 for cheap status summarization
- [ ] Build HaikuSummarizer class with caching
- [ ] Add context-aware prompt templates for different agent types
- [ ] Implement rate limiting for API calls
- [ ] Create fallback descriptions for API failures

**Acceptance Criteria**:
- Contextual, magical status descriptions
- Cost under $0.01 per typical user session
- 500ms max latency for status updates
- Meaningful fallbacks when summarization fails

### Phase 5: Polish and Interactions (Week 9-10)
**Goal**: Professional, interactive experience

**Tasks**:
- [ ] Add click interactions for agent expansion
- [ ] Implement agent execution history/logs
- [ ] Create context menus for agent actions
- [ ] Add sidebar collapse/expand animations
- [ ] Implement export functionality for debugging
- [ ] Performance optimization for large agent hierarchies

**Acceptance Criteria**:
- Responsive interactions under 100ms
- Useful debugging information for developers
- Smooth sidebar state transitions
- Handles 20+ concurrent agents gracefully

## Performance Considerations

### Animation Performance

**Target Specifications**:
- 60 FPS on 2019+ MacBook Pro
- 120 FPS on ProMotion displays when available
- Graceful degradation on older hardware
- Battery impact under 2% during typical use

**Optimization Strategies**:
- Canvas-based particles instead of View-based for high counts
- Particle pooling to avoid allocation overhead
- Frame rate adaptation based on system performance
- Animation complexity scaling with hardware capabilities

**Memory Management**:
```swift
class AgentVisualizationManager: ObservableObject {
    private let maxHistorySize = 50  // Limit completed agent storage
    private let particlePool = ParticlePool(size: 200)  // Reuse particles
    private var animationTimer: Timer?  // Lifecycle management

    func cleanupCompletedAgents() {
        // Remove agents older than 5 minutes or beyond history limit
        completedAgents = completedAgents
            .filter { Date().timeIntervalSince($0.completionTime) < 300 }
            .suffix(maxHistorySize)
    }
}
```

### Real-time Update Efficiency

**SSE Event Handling**:
- Batch multiple agent updates into single UI refresh
- Debounce rapid status changes (max 2 updates/second per agent)
- Prioritize visible agents for summary generation
- Queue background updates when sidebar is collapsed

**Cost Management**:
- Cache Haiku summaries for identical contexts (5-minute TTL)
- Rate limit to 10 summary generations per minute
- Fallback to template-based descriptions under high load
- User setting to disable summaries for cost control

## Future Enhancements

### Advanced Interactions
- **Agent Debugging**: Click agent to see full execution trace with tool calls
- **Performance Metrics**: Show agent CPU/memory usage and execution time
- **Agent Communication**: Visualize data flow between parent/child agents
- **Custom Agent Icons**: User-configurable spell themes and icon sets

### Intelligence Features
- **Predictive Status**: Use agent history to predict completion times
- **Workload Balancing**: Visual indicators when agents are resource-constrained
- **Pattern Recognition**: Highlight frequently used agent combinations
- **Learning Integration**: Adapt animations based on user interaction patterns

### Platform Integration
- **Menu Bar Summary**: Show active agent count in status bar
- **Notification Center**: Agent completion notifications
- **Shortcuts Integration**: Trigger agent analysis via macOS shortcuts
- **Accessibility**: VoiceOver descriptions of agent activity

## Success Metrics

### User Experience Goals
- **Transparency**: 90% of users understand what Claude Code is doing during complex requests
- **Engagement**: 40% increase in user confidence when working with complex tasks
- **Performance**: Zero perceived latency impact on core functionality
- **Accessibility**: Full compatibility with assistive technologies

### Technical Benchmarks
- **Animation Performance**: Consistent 60+ FPS during active agent work
- **Memory Usage**: Under 50MB additional RAM for agent visualization
- **Battery Impact**: Less than 2% additional drain during normal use
- **API Cost**: Under $0.02 per typical user session for status summaries

This magical agent visualization system transforms Claude Code from a mysterious black box into an enchanting, transparent collaboration between user and AI. By revealing the autonomous orchestration of specialized agents, we create not just better software, but a fundamentally more engaging and trustworthy AI experience.