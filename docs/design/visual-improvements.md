# Visual Improvements - Consolidated Plan

**Status**: 📋 PLANNED
**Consolidates**: visual-polish-plan.md, visual-polish-sprint-notes.md, polish-tooling.md
**Aligned with**: aesthetic-system.md (Sophisticated Simplicity vision)

---

## Overview

This document consolidates all visual polish work for the Familiar app. The goal is to transform the current functional interface into a **sophisticated, joyful experience** that delights users while maintaining clarity and accessibility.

### Design Philosophy

Following the principles in `aesthetic-system.md`:
- **Sophisticated Simplicity**: Clean, refined, immediately understandable
- **Joy Through Interaction**: Delight comes from how it works, not decoration
- **Human Language**: "Is that ok?" not "Approve?"
- **Hidden Depth**: Discoverable features for curious users (see `hidden-delights.md`)

**The Ive Test**: Is it inevitable? Essential? Does it show care? Is the design invisible?

---

## Canonical Design Tokens (Locked)

**These values are from `aesthetic-system.md` and are LOCKED.** All implementation must use these tokens.

### Spacing (8pt Rhythm)
- `xs: 8pt` — Tight inline
- `sm: 16pt` — Related components
- `md: 24pt` — Component groups
- `lg: 32pt` — Sections
- `xl: 48pt` — Major regions

**Grid**: Everything snaps to 8pt grid

### Corner Radius
- `control: 8pt` — Buttons, fields, small UI
- `card: 16pt` — Panels, sheets, containers

### Motion
- `interactive: 200ms` — Button press, tap feedback
- `contextual: 250ms` — Sheet, overlay, status
- **The Familiar Spring**: `response: 0.3, dampingFraction: 0.7`

### Colors
**System semantic only** (adapts to light/dark/high-contrast):
- Background, surface, text → system colors
- Success, warning, error, info → system semantic
- **Accent**: System default (or one custom if tested)

**No hex colors except the single accent** (ensures dark mode compatibility)

### Window Geometry
- Min size: 600×400
- Preferred: 720×600
- Corner radius: 16pt
- Interior padding: 24pt
- Shadow: y:4 blur:16 opacity:0.12

### Progress
- **Default**: Breathing dot (subtle)
- **Spinner threshold**: 600ms (rare, long ops only)

### Streaming (Zero Jitter)
- Fixed line height: 24pt
- Max width: 680pt
- Batch tokens: 5 at a time
- Scroll threshold: 20pt from bottom

**See `aesthetic-system.md` for complete tokens and implementation examples.**

---

## Design Audit Summary

**Current State (Sept 2025)**:
- ✅ Functional layout with clear information hierarchy
- ✅ Proper SwiftUI patterns (StateObject, Task, AsyncStream)
- ⚠️ Generic system fonts and colors - lacks personality
- ⚠️ Inconsistent spacing and padding across views
- ⚠️ No visual feedback for state transitions
- ⚠️ Approval sheet feels utilitarian, not trustworthy
- ⚠️ Settings window cramped with nested controls

---

## Quick Wins (1-2 Week Sprint)

### 1. **Prompt Composer Refinement**
**Current**: Gray border, generic placeholder
**Improved**:
- Replace `Color.secondary.opacity(0.2)` with `Color.accentColor.opacity(0.35)`
- Add subtle inner shadow for depth: `.shadow(color: .black.opacity(0.08), radius: 2, x: 0, y: 1)`
- Italicize preview text: `.italic().foregroundStyle(.quaternary)`
- Increase corner radius to 12pt for modern feel

**Files**: `PromptTextEditor.swift:48-50`

### 2. **Send/Stop Button Labels**
**Current**: Icon-only buttons
**Improved**:
- Use `Label("Send", systemImage: "paperplane.fill")` for clarity
- Apply `.buttonStyle(.borderedProminent)` with `.controlSize(.large)`
- Add distinct colors: Send (accent), Stop (orange/warning)
- Ensure 44pt minimum tap target for accessibility

**Files**: `FamiliarWindow.swift:103-119`

### 3. **Transcript Grouping**
**Current**: Single monospaced text block
**Improved**:
- Create `TranscriptEntryView` component with alternating backgrounds
- User messages: default background
- Assistant messages: `.background(Color.accentColor.opacity(0.05))`
- Add timestamp chips: `Text(timestamp).font(.caption2).foregroundStyle(.secondary)`
- Subtle dividers between exchanges

**Files**: `FamiliarWindow.swift:51-71`

### 4. **Error/Loading Feedback**
**Current**: Inline red Label + generic ProgressView
**Improved**:
- Create `StatusBannerView` component with:
  - Rounded rectangle with tinted background
  - Leading icon (error/warning/info)
  - Action button for "View Details" or "Retry"
- Loading: Status pill above composer with spinner + short message
- Error: Prominent banner with helpful recovery actions

**Files**: `FamiliarWindow.swift:64-67, 78-86`

### 5. **Usage Summary Hierarchy**
**Current**: Plain VStack with small text
**Improved**:
- Promote "Session" to accent-colored `Label` with bullet
- Format currency consistently (avoid repeated NumberFormatter)
- Use card background with subtle padding
- Collapse by default, expand on click

**Files**: `UsageSummaryView.swift`

### 6. **Settings Status Banner**
**Current**: Conditional Text with color
**Improved**:
- Wrap in `SettingsStatusCard` with:
  - Icon (checkmark/warning/info)
  - Tinted background (green.opacity(0.15) for success)
  - Optional action link ("Test Connection", "Sign In")
- Smooth animations when status changes

**Files**: `SettingsView.swift:60-64`

### 7. **Approval Sheet Diff Legibility**
**Current**: Plain text diff in scroll view
**Improved**:
- Create `DiffLineView` with per-line backgrounds:
  - Additions: `Color.green.opacity(0.12)`
  - Deletions: `Color.red.opacity(0.12)`
- Increase monospace font size from 11pt to 12pt
- Add line numbers in gutter
- Syntax highlighting for file extensions (basic)

**Files**: `ApprovalSheet.swift`

---

## Design Token System (Sprint 2)

### Color Tokens
```swift
extension Color {
    // Surface hierarchy
    static let surfaceBase = Color(nsColor: .controlBackgroundColor)
    static let surfaceElevated = Color(nsColor: .windowBackgroundColor)
    static let surfaceOverlay = Color(nsColor: .underPageBackgroundColor)

    // Semantic colors
    static let accentSuccess = Color.green
    static let accentWarning = Color.orange
    static let accentError = Color.red
    static let accentInfo = Color.blue

    // Familiar brand (to be defined)
    static let familiarPrimary = Color.accentColor
    static let familiarSecondary = Color.purple.opacity(0.7)
}
```

### Typography Scale
```swift
extension Font {
    static let familiarTitle = Font.system(.title2, design: .rounded, weight: .semibold)
    static let familiarHeading = Font.system(.headline, design: .default)
    static let familiarBody = Font.system(.body, design: .default)
    static let familiarCaption = Font.system(.caption, design: .default)
    static let familiarMono = Font.system(.body, design: .monospaced)
}
```

### Spacing Constants
```swift
enum Spacing {
    static let xxs: CGFloat = 2
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 24
    static let xxl: CGFloat = 32
}
```

---

## Component Card System (Sprint 2)

### Reusable Card Style
```swift
struct CardStyle: ViewModifier {
    var padding: CGFloat = 16
    var background: Color = .surfaceElevated

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(background)
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.06), radius: 8, y: 2)
    }
}

extension View {
    func cardStyle(padding: CGFloat = 16, background: Color = .surfaceElevated) -> some View {
        modifier(CardStyle(padding: padding, background: background))
    }
}
```

### Usage Examples
```swift
// Transcript entry
TranscriptEntryView(...)
    .cardStyle(padding: 12)

// Tool summary
ToolSummaryView(...)
    .cardStyle(background: .surfaceOverlay)

// Settings section
VStack {
    // API key fields
}
.cardStyle(padding: 20)
```

---

## Motion & Animation Polish (Sprint 3)

### Principles
- **Purposeful**: Every animation communicates state change
- **Fast**: 0.2-0.3s for most transitions, never > 0.5s
- **Accessible**: Respect `prefersReducedMotion`
- **Consistent**: Reuse animation curves across components

### Animation Library
```swift
extension Animation {
    static let familiarSpring = Animation.spring(response: 0.3, dampingFraction: 0.7)
    static let familiarEaseOut = Animation.easeOut(duration: 0.25)
    static let familiarEaseInOut = Animation.easeInOut(duration: 0.2)
}
```

### Key Animations

1. **Send Button Press**
   - Scale down to 0.95 on press
   - Pulse accent color on successful send
   - Spring back to 1.0

2. **Approval Sheet Entrance**
   - Slide up from bottom with ease-out
   - Backdrop fade in over 0.2s
   - Diff content delays 0.1s for polish

3. **Loading Spinner Transition**
   - Fade in over 0.15s
   - Rotate continuously (360° / 1s)
   - Fade out with scale-down (0.9)

4. **Status Banner Appearance**
   - Slide down from top with spring
   - Auto-dismiss after 3s with fade-out
   - User can swipe to dismiss early

---

## Empty & Success States (Sprint 3)

### Empty Transcript State
```
┌─────────────────────────┐
│                         │
│     ✨ Ready to help    │
│                         │
│  Ask me anything about  │
│  your codebase...       │
│                         │
│  Try:                   │
│  • "Explain auth.ts"    │
│  • "Add error handling" │
│  • "Run the tests"      │
│                         │
└─────────────────────────┘
```

### Success Confirmation
- Green checkmark animation (scale + fade)
- Brief "Done!" message
- Tool summary card with results
- Option to copy output or open file

---

## Moments of Delight (Sprint 3-4)

### Philosophy

Following Jony Ive's principle: delight comes from **how it works**, not from decoration.

**Good delight**:
- Purposeful animations that communicate state
- Satisfying confirmation of actions
- Subtle surprises that reward attention
- Details that show care

**Bad delight**:
- Random confetti or animations
- Cutesy mascots or illustrations
- Decoration without function
- Gimmicks that get old quickly

### The Distinctive Element: Motion ⭐

**Decision locked**: Signature motion is Familiar's distinctive element.

**The "Familiar Spring"** — consistent across all interactions:

```swift
extension Animation {
    static let familiar = Animation.spring(
        response: 0.3,
        dampingFraction: 0.7
    )
}

// Convenience variants
extension Animation {
    static let familiarInteractive = familiar.speed(0.2 / 0.3)  // Button presses
    static let familiarContextual = familiar.speed(0.25 / 0.3)   // Sheets, overlays
}
```

**Why motion (not sound or color)**:
- **Universal**: Everyone experiences it
- **Ive-like**: iPhone's fluid animations defined the brand
- **No permissions**: Works immediately
- **All contexts**: Quiet meetings, voice mode, any environment
- **Accessible**: Can be reduced while maintaining feel
- **Testable**: 1-2 week prototype validates it

**Applied consistently**:
- Button press feedback
- Sheet presentations
- Status transitions
- Success confirmations
- All UI state changes

**The result**: Familiar feels **alive and responsive** in a recognizable way.

### Audio: Minimal and Optional

**Default: Silent** (following Ive's principle)

**Voice output**: Natural when user enables voice mode
**UI sounds**: Off by default, optional confirmation tone only

See `aesthetic-system.md` for full audio philosophy.

### Micro-Interactions That Bring Joy

#### Success Celebration

**When**: Task completes successfully

**Animation**:
```swift
// Subtle success pulse
withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
    scale = 1.05
}
DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
        scale = 1.0
    }
}
```

**Sound**: Completion chime

**Visual**: Brief checkmark animation

**Purpose**: Acknowledge work complete, feel satisfying

#### Button Press Feedback

**Current**: Standard SwiftUI button
**Improved**: Tactile feel

```swift
struct TactileButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
            .brightness(configuration.isPressed ? -0.05 : 0)
    }
}
```

**Purpose**: Feels responsive and alive

#### Inline Approvals (New Pattern)

**Critical insight from critique**: Sheets are ceremonious. Use them sparingly.

**Pattern**: Inline approval for everyday actions

**Common actions** (use inline, not sheet):
- Edit a file
- Run a command
- Create a document
- Organize files

**Visual**:
```
┌─────────────────────────────────────┐
│ I can organize your desktop:        │
│ • 47 images → "Images" folder       │
│ • 23 PDFs → "Documents" folder      │
│                                     │
│ Is that ok?                         │
│ [Show how ▼] [Not now] [Yes, do it]│
└─────────────────────────────────────┘
```

**Appears inline** in the conversation flow, not as interrupting sheet.

**Rare/consequential actions** (use sheet):
- Always allow permission
- Delete files
- Major destructive operations

**Purpose**: Less ceremony, better flow, trust through clarity

#### Sheet Entrance (When Needed)

**For rare consequential actions only**:

- Slides up with ease-out curve
- Content fades in with 0.1s delay
- Backdrop darkens smoothly
- Diff preview has additional 0.1s delay

**Purpose**: Draw attention to important decision

#### Progress Indication (Not Spinner)

**Critical insight from critique**: Spinner is visual noise. Use subtle progress affordance.

**Default: Breathing Dot**

```swift
struct BreathingDot: View {
    @State private var opacity: Double = 0.3

    var body: some View {
        Circle()
            .fill(Color.accentColor)
            .frame(width: 8, height: 8)
            .opacity(opacity)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 1.0)
                    .repeatForever(autoreverses: true)
                ) {
                    opacity = 1.0
                }
            }
    }
}
```

**Placement**: Next to prompt field or in status bar

**Alternative**: Animated underline below prompt field

**Spinner**: Only after 600ms threshold (rare, long operations only)

**Why breathing dot**:
- Subtle, not intrusive
- Calm confidence (no spinning anxiety)
- Matches "silent operation" principle
- Can be overlooked without missing information

**Purpose**: Communicate progress without creating visual noise

#### First Keystroke Magic

**When**: User starts typing in prompt field

**Behavior**:
- Zero state fades out **instantly** (no delay)
- Cursor is already active
- No lag between intent and action

**Purpose**: User feels in control, no friction

**Implementation**:
```swift
TextField("", text: $prompt)
    .onChange(of: prompt) { _ in
        withAnimation(.easeOut(duration: 0.2)) {
            showZeroState = false
        }
    }
```

#### Returning to Empty

**When**: User clears transcript, back to zero state

**Behavior**:
- Zero state fades in (0.3s)
- Suggestions appear sequentially (0.1s stagger)
- Feels alive, not static

**Purpose**: Always welcoming, never stale

### Hidden Delights Integration

From `hidden-delights.md`, subtle visual treats:

#### Midnight Mode Visual Shift

**When**: 12:00-1:00 AM

**Changes**:
- Background slightly deeper
- Accent color shifts to moonlight blue
- Status bar shows "🌙 The witching hour"

**Purpose**: Reward night owls, add personality

#### Long-Press Menu Icon

**Trigger**: Long-press menu bar icon

**Response**: Brief sigil animation pulse

**Purpose**: Hidden visual treat

#### Konami Code Response

**Trigger**: ↑↑↓↓←→←→BA

**Response**: Window briefly shows sigil animation with "You found the old magic ✨"

**Purpose**: Classic easter egg

### Language Updates (Human, Not Corporate)

Following "Is that ok?" philosophy:

#### Button Text Changes

**Before** → **After**:
- "Approve" → "Sounds good" / "Yes, do it"
- "Deny" → "Not right now"
- "Cancel" → "Never mind"
- "Apply" → "Save these"
- "Execute" → "Go ahead"
- "Confirm" → "That's right"

#### Status Messages

**Before** → **After**:
- "Initializing..." → "Starting up..."
- "Operation completed" → "Done!"
- "Error occurred" → "Hmm, something went wrong"
- "Permission denied" → "I'm not allowed to do that"
- "Processing..." → "Working on it..."

#### Approval Dialog Rewrite

**Before**:
```
Familiar wants to modify files:
• /Users/alex/Desktop/file.txt
• /Users/alex/Documents/notes.md

[Cancel] [Approve]
```

**After**:
```
I can organize your files for you:
• Move 47 images to "Images" folder
• Move 23 PDFs to "Documents" folder

Is that ok?

[Show me how ▼] [Not right now] [Yes, do it]
```

---

## Accessibility Sweep (Sprint 4)

### Checklist
- [ ] All buttons have `.accessibilityLabel()` with action verb
- [ ] Color is not the only indicator (icons + text)
- [ ] Contrast ratio >= 4.5:1 for body text, >= 3:1 for large text
- [ ] Focus order follows visual hierarchy (tab navigation)
- [ ] VoiceOver announces state changes (streaming, errors, completion)
- [ ] Animations respect `accessibilityReduceMotion` setting
- [ ] Minimum 44pt tap targets for all interactive elements
- [ ] Keyboard shortcuts documented in `.help()` modifiers

### Testing Script
```bash
# Run accessibility inspector
./scripts/accessibility-check.sh

# Manual VoiceOver test
1. Enable VoiceOver (Cmd+F5)
2. Navigate through Familiar window
3. Verify all controls are announced
4. Test approval sheet interaction
5. Check settings navigation
```

---

## Tooling & Validation

### Screenshot Comparison
```bash
# Before/after visual regression
./scripts/screenshot-compare.sh FamiliarView before.png after.png
```

### Color Contrast Checker
```bash
# Validate WCAG compliance
./scripts/color-contrast-checker.sh --bg "#0B0C10" --fg "#F4EDE1"
# Result: 12.3:1 (AAA) ✅
```

### Performance Profiling
```bash
# Measure animation FPS
# Xcode > Instruments > Core Animation
# Target: 60fps sustained during active streaming
```

---

## Implementation Priority

### Phase 1: Foundation (Weeks 1-2)
1. Language audit - update all text to "Is that ok?" philosophy
2. Quick Wins #1-3 (Prompt, Buttons, Transcript)
3. Quick Wins #4-7 (Status, Usage, Settings, Diff)

### Phase 2: Distinctive Element (Week 3)
4. Decide on signature element (sound / motion / color)
5. Design Tokens + Component Card System
6. Implement signature sound palette (recommended)

### Phase 3: Micro-Delights (Week 4)
7. Motion & Animation Polish
8. Joyful micro-interactions (success, button feedback, transitions)
9. Empty States + Success Confirmations

### Phase 4: Polish & Accessibility (Weeks 5-6)
10. Hidden delights integration (easter eggs)
11. Accessibility Sweep + Validation
12. Performance testing and optimization

### Continuous
- Voice integration (parallel track, see voice-assistant.md)
- Zero state implementation (see intelligent-zero-state.md)

---

## Success Metrics

**Before** (Current):
- User feedback: "Functional but bland"
- Task completion: Works but lacks confidence
- Aesthetic score: 4/10

**After** (Target):
- User feedback: "Polished and trustworthy"
- Task completion: Clear status, reduced anxiety
- Aesthetic score: 8/10

**Measurable Goals**:
- Zero contrast violations (WCAG AA minimum)
- 100% VoiceOver navigation success
- 60fps animations on 2019+ MacBook Pro
- <100ms perceived latency for status updates

---

## Related Documents

### Essential Reading Before Implementation

- **`aesthetic-system.md`**: Core design philosophy (sophisticated simplicity)
- **`hidden-delights.md`**: Easter eggs and discoverable depth
- **`voice-assistant.md`**: Voice interface integration
- **`intelligent-zero-state.md`**: Smart suggestions system

### Design Philosophy Summary

From `aesthetic-system.md`:

**The Four Principles**:
1. **Clarity Over Decoration**: Every element serves communication
2. **Joy Through Interaction**: Delight from how it works, not how it looks
3. **Human Language**: "Is that ok?" not "Approve?"
4. **Mystery Through Discovery**: Hidden depth for curious users

**The Ive Test**:
- Is it inevitable? (feels obvious in hindsight)
- Is it essential? (nothing superfluous)
- Does it show care? (attention to detail perceptible)
- Is the design invisible? (user thinks about task, not UI)

---

## Notes for Future Developers

### Core Guidelines

- **Don't Sacrifice Clarity**: Visual polish should enhance, not obscure information
- **Function Over Ornamentation**: Every animation, sound, color choice must have purpose
- **Test on Multiple Displays**: Ensure colors work in light mode and dark mode
- **Profile Animations**: Canvas operations can be expensive; use Instruments
- **Respect Accessibility**: VoiceOver, keyboard nav, reduced motion - non-negotiable
- **Iterate with Users**: Get feedback early on visual changes
- **Document Decisions**: Update this file when introducing new patterns

### The Language Test

Before shipping any user-facing text, ask:
- Would I say this to a friend?
- Or does it sound corporate/robotic?

**Examples**:
- ✅ "Is that ok?"
- ❌ "Approve this action?"
- ✅ "Done!"
- ❌ "Operation completed successfully"
- ✅ "Hmm, I can't access that file"
- ❌ "Error: Permission denied [Errno 13]"

### The Distinctive Element Decision

**Current recommendation**: Signature sound palette

**Why**:
- Most memorable (like iPhone's lock sound)
- Works with voice-first interface
- Accessible without being intrusive
- Sophisticated, not gimmicky

**Alternatives documented** in case sound doesn't work out:
- Signature motion language (spring animations)
- Signature color accent (sophisticated non-standard color)

### Hidden Delights Guidelines

From `hidden-delights.md`:

**Add easter eggs that**:
- Delight without confusing
- Never interfere with core functionality
- Work with accessibility features
- Reward curiosity and exploration

**Don't add**:
- Random behavior (must be deterministic)
- Confusing UX changes
- Features that require explanation
- Things that violate accessibility

### V27 Magic Mode

**Long-term aspiration** (see `hidden-delights.md`):
- Optional hermetic aesthetic overlay
- Hidden toggle for fellow mystics
- Preserves mystical soul without compromising accessibility
- "Cope that becomes real"

**Not promised, but documented. The magic is preserved.**

---

**Last Updated**: September 30, 2025
**Status**: 📋 Ready for sprint planning, aligned with sophisticated simplicity vision