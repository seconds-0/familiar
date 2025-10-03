# Aesthetic Foundation Implementation Plan

**Status**: 🚧 IN PROGRESS
**Branch**: `feature/aesthetic-foundation`
**Timeline**: 3 weeks (Foundation + Zero State)
**Started**: September 30, 2025

---

## Overview

This plan implements the design foundation established in `aesthetic-system.md`, then builds the intelligent zero state on top of that foundation. The goal is to transform Familiar from functional to delightful while maintaining sophisticated simplicity.

### Why Foundation First?

Following the aesthetic-system.md philosophy: build the invisible foundation first (design tokens, motion system), then layer on visible features (zero state, polish). Each component inherits quality automatically rather than requiring retrofit.

**The Ive Test**: Is it inevitable? Essential? Does it show care? Is the design invisible?

---

## Phase 1: Design System Foundation (Weeks 1-2)

**Goal**: Establish the aesthetic bedrock that everything else builds on.

### 1.1 Design Tokens System

**Files to create**:

- `apps/mac/FamiliarApp/Sources/FamiliarApp/Design/FamiliarSpacing.swift`
- `apps/mac/FamiliarApp/Sources/FamiliarApp/Design/FamiliarRadius.swift`
- `apps/mac/FamiliarApp/Sources/FamiliarApp/Design/FamiliarTypography.swift`
- `apps/mac/FamiliarApp/Sources/FamiliarApp/Design/FamiliarColor.swift`
- `apps/mac/FamiliarApp/Sources/FamiliarApp/Design/FamiliarMotion.swift`

**Implementation**:

#### Spacing (8pt Rhythm)

```swift
enum FamiliarSpacing {
    static let xs: CGFloat = 8    // Tight inline elements
    static let sm: CGFloat = 16   // Related components
    static let md: CGFloat = 24   // Component groups
    static let lg: CGFloat = 32   // Sections
    static let xl: CGFloat = 48   // Major regions
}
```

#### Corner Radius

```swift
enum FamiliarRadius {
    static let control: CGFloat = 8   // Buttons, fields, small UI
    static let card: CGFloat = 16     // Panels, sheets, containers
}
```

#### Typography

```swift
extension Font {
    static let familiarTitle = Font.system(.title2, design: .default, weight: .semibold)
    static let familiarHeading = Font.system(.headline, design: .default, weight: .medium)
    static let familiarBody = Font.system(.body, design: .default, weight: .regular)
    static let familiarCaption = Font.system(.caption, design: .default, weight: .regular)
    static let familiarMono = Font.system(.body, design: .monospaced, weight: .regular)
}
```

#### Colors (System Semantic)

```swift
extension Color {
    // Foundation
    static let familiarBackground = Color(nsColor: .windowBackgroundColor)
    static let familiarSurfaceElevated = Color(nsColor: .controlBackgroundColor)
    static let familiarTextPrimary = Color.primary
    static let familiarTextSecondary = Color.secondary

    // Semantic
    static let familiarSuccess = Color.green
    static let familiarWarning = Color.orange
    static let familiarError = Color.red
    static let familiarInfo = Color.blue

    // Accent
    static let familiarAccent = Color.accentColor
}
```

#### Motion (The Familiar Spring)

```swift
extension Animation {
    // The signature spring
    static let familiar = Animation.spring(
        response: 0.3,
        dampingFraction: 0.7
    )

    // Convenience variants
    static let familiarInteractive: Animation = {
        familiar.speed(0.2 / 0.3)  // 200ms for button presses
    }()

    static let familiarContextual: Animation = {
        familiar.speed(0.25 / 0.3)  // 250ms for sheets, overlays
    }()
}
```

**Checklist**:

- [ ] Create Design/ directory
- [ ] Implement FamiliarSpacing.swift
- [ ] Implement FamiliarRadius.swift
- [ ] Implement FamiliarTypography.swift
- [ ] Implement FamiliarColor.swift
- [x] Implement FamiliarMotion.swift
- [x] Add unit tests for token values
- [x] Document usage in code comments

**Reference**: aesthetic-system.md:522-663

---

### 1.2 Language Audit & Updates

**Goal**: Replace all corporate language with human, friendly language following "Is that ok?" philosophy.

**Files to audit**:

- `ApprovalSheet.swift` - "Approve?" → "Yes, do it"
- `SettingsView.swift` - Various button labels
- `FamiliarWindow.swift` - Status messages
- `FamiliarViewModel.swift` - Error messages
- `ToolSummaryView.swift` - Display text

**Language Guidelines**:

**Do**:

- "Is that ok?"
- "Yes, do it" / "Sounds good"
- "Not right now" / "No thanks"
- "Show me how"
- "Done!"
- "Hmm, something went wrong"

**Don't**:

- "Approve?"
- "Confirm"
- "Deny" / "Cancel"
- "Show details"
- "Operation completed successfully"
- "Error: [technical message]"

**Checklist**:

- [x] Audit ApprovalSheet.swift button text
- [x] Update SettingsView.swift labels
- [x] Review FamiliarWindow.swift status messages
- [x] Update error messages in FamiliarViewModel.swift
- [x] Check ToolSummaryView.swift for corporate language
- [x] Test all text changes in light and dark mode
- [x] Verify VoiceOver reads naturally

**Reference**: aesthetic-system.md:283-313, visual-improvements.md:584-627

---

### 1.3 Quick Wins from Visual Improvements

#### 1.3.1 Prompt Composer Refinement

**File**: `PromptTextEditor.swift`

**Current state**: Gray border, generic placeholder

**Changes**:

- Replace border color with `Color.familiarAccent.opacity(0.35)`
- Add subtle inner shadow for depth
- Italicize preview text with quaternary color
- Increase corner radius to 12pt (using `FamiliarRadius.field`)
- Use `FamiliarSpacing` for padding

**Checklist**:

- [x] Update border styling
- [x] Add inner shadow
- [x] Style preview text (italic + tertiary)
- [x] Apply corner radius from tokens (`FamiliarRadius.field`)
- [x] Apply spacing from tokens (16/8)
- [x] Test in light/dark mode

**Reference**: visual-improvements.md:91-99

#### 1.3.2 Send/Stop Button Labels

**File**: `FamiliarWindow.swift:103-119`

**Current state**: Icon-only buttons

**Changes**:

- Use `Label("Send", systemImage: "paperplane.fill")`
- Apply `.buttonStyle(.borderedProminent)` with `.controlSize(.large)`
- Send button: accent color
- Stop button: orange/warning color
- Ensure 44pt minimum tap target
- Use `FamiliarTypography.familiarBody` for text

**Checklist**:

- [x] Add text labels to buttons
- [x] Apply button styles
- [x] Set distinct colors
- [x] Verify 44pt tap targets
- [x] Test accessibility with VoiceOver
- [x] Add keyboard shortcuts hints

**Reference**: visual-improvements.md:102-109

#### 1.3.3 Breathing Dot Progress Indicator

**File**: New component `BreathingDotView.swift`

**Purpose**: Replace spinner with subtle progress affordance

**Implementation**:

```swift
struct BreathingDotView: View {
    @State private var opacity: Double = 0.3

    var body: some View {
        Circle()
            .fill(Color.familiarAccent)
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

**Integration**: Replace `ProgressView()` in FamiliarWindow.swift

**Checklist**:

- [x] Create BreathingDotView.swift
- [x] Implement breathing animation
- [x] Replace spinner in FamiliarWindow
- [x] Position next to prompt field
- [x] Test animation with reduced motion preference
- [x] Verify 60fps performance

**Reference**: aesthetic-system.md:666-693, visual-improvements.md:480-519

#### 1.3.4 Consistent Spacing Application

**Files**: All UI components

**Goal**: Apply 8pt grid spacing consistently across all views

**Changes needed**:

- Replace hardcoded padding values with `FamiliarSpacing` tokens
- Ensure all layouts snap to 8pt grid
- Use `.padding(FamiliarSpacing.sm)` instead of `.padding(16)`

**Priority files**:

1. `FamiliarWindow.swift` - Main layout
2. `ApprovalSheet.swift` - Sheet spacing
3. `SettingsView.swift` - Settings sections
4. `ToolSummaryView.swift` - Tool cards
5. `UsageSummaryView.swift` - Usage display

**Checklist**:

- [x] Audit all padding/spacing in FamiliarWindow.swift
- [x] Update ApprovalSheet.swift spacing
- [x] Apply tokens to SettingsView.swift
- [x] Fix ToolSummaryView.swift layout
- [x] Update UsageSummaryView.swift spacing
- [x] Visual regression test all screens
- [x] Verify layouts at different window sizes

**Reference**: visual-improvements.md:526-537

---

### 1.4 The Familiar Spring Integration

**Goal**: Apply signature motion to all interactive elements

**Files to update**:

- `FamiliarWindow.swift` - Button presses, status transitions
- `ApprovalSheet.swift` - Sheet presentation
- `SettingsView.swift` - Setting toggles
- Any custom button components

**Pattern**:

```swift
// Interactive elements (buttons, taps)
.animation(.familiarInteractive, value: isPressed)

// Contextual elements (sheets, overlays)
.animation(.familiarContextual, value: isPresented)

// All other state changes
.animation(.familiar, value: someState)
```

**Checklist**:

- [ ] Apply to send button press feedback
- [ ] Add to approval sheet presentation
- [ ] Use for status transitions in main window
- [ ] Apply to settings toggles
- [ ] Test with reduced motion enabled
- [ ] Verify smooth 60fps animations
- [ ] Document animation usage patterns

**Reference**: aesthetic-system.md:465-519, visual-improvements.md:260-298

---

## Phase 2: Zero State Implementation (Week 3)

**Goal**: Beautiful welcome experience built on the solid foundation.

### 2.1 Zero State View Component

**File**: New component `ZeroStateView.swift`

**Design**:

```
┌─────────────────────────────────────────┐
│                                         │
│     What can I help you with today?     │
│                                         │
│  ┌────────────────────────────────────┐│
│  │ 📋 Organize cluttered desktop      ││
│  └────────────────────────────────────┘│
│                                         │
│  ┌────────────────────────────────────┐│
│  │ ✨ Create something from scratch   ││
│  └────────────────────────────────────┘│
│                                         │
│  ┌────────────────────────────────────┐│
│  │ 🔍 Research anything you're        ││
│  │    curious about                   ││
│  └────────────────────────────────────┘│
│                                         │
│  ┌────────────────────────────────────┐│
│  │ 🎁 Surprise me with something      ││
│  │    useful                          ││
│  └────────────────────────────────────┘│
│                                         │
│                                         │
│  Or just type what you need...         │
│  ┌────────────────────────────────────┐│
│  │                                    ││
│  └────────────────────────────────────┘│
└─────────────────────────────────────────┘
```

**Implementation**:

```swift
struct ZeroStateView: View {
    let onSuggestionTap: (String) -> Void
    @State private var suggestions: [String] = []

    var body: some View {
        VStack(spacing: FamiliarSpacing.md) {
            Text("What can I help you with today?")
                .font(.familiarTitle)
                .foregroundStyle(.familiarTextPrimary)
                .padding(.top, FamiliarSpacing.xl)

            VStack(spacing: FamiliarSpacing.sm) {
                ForEach(suggestions, id: \.self) { suggestion in
                    SuggestionCard(text: suggestion) {
                        onSuggestionTap(suggestion)
                    }
                }
            }

            Text("Or just type what you need...")
                .font(.familiarCaption)
                .foregroundStyle(.familiarTextSecondary)
                .padding(.bottom, FamiliarSpacing.md)
        }
        .padding(FamiliarSpacing.lg)
        .onAppear {
            loadSuggestions()
        }
    }

    private func loadSuggestions() {
        suggestions = SuggestionGenerator.generate(
            timeOfDay: Date.timeOfDay,
            dayOfWeek: Date.dayOfWeek
        )
    }
}
```

**Checklist**:

- [ ] Create ZeroStateView.swift
- [ ] Create SuggestionCard.swift component
- [ ] Implement suggestion rotation logic
- [ ] Add fade-in animation with stagger
- [ ] Test click interaction
- [ ] Test fade-out on typing
- [ ] Verify spacing using design tokens
- [ ] Test VoiceOver navigation

**Reference**: intelligent-zero-state.md:325-357

---

### 2.2 Suggestion Generator (V1 - Static)

**File**: New file `SuggestionGenerator.swift`

**Purpose**: Generate contextually relevant suggestions based on time/day

**Implementation**:

```swift
enum SuggestionGenerator {
    static func generate(timeOfDay: TimeOfDay, dayOfWeek: DayOfWeek) -> [String] {
        var suggestions: [String] = []

        // Always show breadth across categories
        suggestions.append(creative.randomElement()!)
        suggestions.append(organization.randomElement()!)
        suggestions.append(research.randomElement()!)

        // Fourth is contextual
        if timeOfDay == .morning {
            suggestions.append("Plan today's priorities")
        } else if dayOfWeek.isWeekend {
            suggestions.append("Help with a weekend project")
        } else {
            suggestions.append(unexpected.randomElement()!)
        }

        return suggestions
    }

    // Suggestion banks
    private static let creative = [
        "Create something from scratch",
        "Write a document or note",
        "Generate an image from description",
        "Design something creative"
    ]

    private static let organization = [
        "Organize cluttered desktop",
        "Sort files by type or date",
        "Clean up downloads folder",
        "Create folder structure"
    ]

    private static let research = [
        "Research anything you're curious about",
        "Learn something new today",
        "Find information about a topic",
        "Compare options for a decision"
    ]

    private static let unexpected = [
        "Surprise me with something useful",
        "Automate a tedious task",
        "Show me something I can do",
        "Make my life easier somehow"
    ]
}
```

**Checklist**:

- [ ] Create SuggestionGenerator.swift
- [ ] Implement 20+ suggestions across categories
- [ ] Add time-based context logic
- [ ] Add day-of-week context logic
- [ ] Test suggestion variety
- [ ] Verify no coding-focused suggestions dominate
- [ ] Unit test generator logic

**Reference**: intelligent-zero-state.md:230-256

---

### 2.3 Suggestion Card Component

**File**: New file `SuggestionCard.swift`

**Purpose**: Beautiful, tappable card for each suggestion

**Implementation**:

```swift
struct SuggestionCard: View {
    let text: String
    let action: () -> Void
    @State private var isHovered = false

    var body: some View {
        Button(action: action) {
            HStack {
                Text(text)
                    .font(.familiarBody)
                    .foregroundStyle(.familiarTextPrimary)
                    .multilineTextAlignment(.leading)
                Spacer()
            }
            .padding(FamiliarSpacing.sm)
            .background(
                RoundedRectangle(cornerRadius: FamiliarRadius.control)
                    .fill(isHovered ? Color.familiarAccent.opacity(0.1) : Color.familiarSurfaceElevated)
            )
        }
        .buttonStyle(.plain)
        .onHover { hovering in
            withAnimation(.familiar) {
                isHovered = hovering
            }
        }
    }
}
```

**Checklist**:

- [ ] Create SuggestionCard.swift
- [ ] Implement hover state
- [ ] Add subtle animation on hover
- [ ] Test click interaction
- [ ] Verify keyboard navigation
- [ ] Test VoiceOver announcement
- [ ] Ensure 44pt minimum height

**Reference**: visual-improvements.md:218-256

---

### 2.4 Integration with FamiliarWindow

**File**: `FamiliarWindow.swift`

**Changes**:

- Show `ZeroStateView` when transcript is empty
- Hide immediately when user starts typing
- Clicking suggestion populates prompt field
- Apply fade animations using `.familiar` spring

**Integration pattern**:

```swift
struct FamiliarWindowContent: View {
    @ObservedObject var viewModel: FamiliarViewModel

    var body: some View {
        ZStack {
            if viewModel.transcript.isEmpty && viewModel.currentPrompt.isEmpty {
                ZeroStateView { suggestion in
                    viewModel.currentPrompt = suggestion
                    viewModel.focusPromptField()
                }
                .transition(.opacity.animation(.familiar))
            }

            // Existing transcript and prompt UI
            VStack {
                // ... existing content
            }
        }
    }
}
```

**Checklist**:

- [ ] Add ZeroStateView to FamiliarWindow
- [ ] Implement show/hide logic
- [ ] Wire up suggestion tap to prompt field
- [ ] Add fade transition with Familiar spring
- [ ] Test typing immediately hides zero state
- [ ] Test clearing transcript shows zero state again
- [ ] Verify smooth animations

**Reference**: intelligent-zero-state.md:542-556

---

## Phase 3: Continued Polish (Weeks 4-6)

**Note**: These can be done incrementally after Phase 1-2 are complete.

### 3.1 Transcript Grouping

**Goal**: Group the transcript by speaker using role-aware surfaces, timestamp chips, and zero-jitter streaming. Replace the monolithic transcript string with structured entries while preserving performance, accessibility, and token usage.

**Why now**: Improves readability and scannability, sets the stage for richer content (code blocks, diffs) in later 3.x tasks, and enforces streaming stability rules from the aesthetic system.

**Files**:

- New: `apps/mac/FamiliarApp/Sources/FamiliarApp/Models/TranscriptEntry.swift`
- New: `apps/mac/FamiliarApp/Sources/FamiliarApp/UI/TranscriptEntryView.swift`
- Update: `apps/mac/FamiliarApp/Sources/FamiliarApp/UI/FamiliarViewModel.swift`
- Update: `apps/mac/FamiliarApp/Sources/FamiliarApp/UI/FamiliarWindow.swift`

---

#### Data Model

- Add `TranscriptEntry` with minimal, stable fields:

  ```swift
  struct TranscriptEntry: Identifiable, Equatable {
      enum Role { case user, assistant, system }
      let id: UUID
      let role: Role
      var text: String
      let timestamp: Date
      var isStreaming: Bool
  }
  ```

- ViewModel migration:
  - Introduce `@Published var entries: [TranscriptEntry] = []`.
  - Keep `transcript` temporarily for fallback; UI will switch to `entries` in this task. Remove `transcript` in 3.1 wrap-up.

---

#### ViewModel Changes

- On submit:
  - Append a `.user` entry with the prompt and `Date()`.
  - Append an empty `.assistant` entry with `isStreaming = true` to receive streamed text.
  - Clear `toolSummary`, `errorMessage`, reset loading state as today.

- On `assistant_text` stream events:
  - Append batch text to the last `.assistant` entry where `isStreaming == true`. If none exists, create it then append.
  - Optional: coalesce chunks (20–30ms window) to avoid UI thrash.

- On `result` or stream completion:
  - Mark the last streaming assistant entry `isStreaming = false`.

- Utilities:
  - Add a static `DateFormatter` for chips (short time). Avoid per-entry formatter allocation.

---

#### UI: TranscriptEntryView

- Create `TranscriptEntryView(entry:)` rendering role, text, and a timestamp chip.

- Styling (use design tokens only):
  - Outer: `RoundedRectangle(cornerRadius: FamiliarRadius.control)` with inner padding `FamiliarSpacing.sm` and vertical spacing `FamiliarSpacing.xs` between entries.
  - User: default surface (no fill), `.font(.familiarBody)`, `.foregroundStyle(.familiarTextPrimary)`.
  - Assistant: background tint `Color.familiarAccent.opacity(0.05)`; same font and text color as user.
  - System (if used): softer surface `Color.secondary.opacity(0.08)` with `.familiarCaption` as appropriate.
  - Timestamp chip: `Text(time).font(.familiarCaption).foregroundStyle(.secondary)`, aligned top- or bottom-trailing.
  - Selection: `.textSelection(.enabled)`.
  - Width: constrain content to a `maxWidth` of 680pt via container to satisfy streaming rules.

---

#### Window Integration

- Replace the single `Text(viewModel.transcript)` with a list of entries:
  - Use `ScrollViewReader` + `ScrollView(.vertical)` + `LazyVStack(spacing: FamiliarSpacing.xs)`.
  - `ForEach(viewModel.entries) { TranscriptEntryView(entry: $0) }`.
  - Maintain existing `ToolSummaryView` and error labels below the transcript stack.

- Scrolling behavior:
  - Auto-scroll to bottom as new text is appended to the active streaming assistant entry.
  - Detect if the user has scrolled up beyond ~20pt from bottom; pause auto-scroll until they return near bottom.
  - Implement with a bottom anchor (`scrollTo(lastId, anchor: .bottom)`) gated by a “userAtBottom” flag.

---

#### Streaming & Zero Jitter

- Enforce constraints from the aesthetic system:
  - Max width: 680pt container.
  - Fixed line height target ~24pt: tune line spacing for `.familiarBody` so measured line height remains stable while streaming.
  - Batch updates: coalesce incoming chunks; never update per character.
  - Fade-in new entries only: `.transition(.opacity.animation(.familiar))`; avoid layout-affecting animations during streaming text changes.

- Performance:
  - Prefer `LazyVStack` and avoid heavy modifiers in `ForEach`.
  - Keep frame and line metrics constant to prevent reflow.

---

#### Accessibility

- VoiceOver:
  - Accessibility labels per entry: “You said … at 10:24 AM” / “Assistant said … at 10:24 AM”.
  - Ensure chips are read once; do not duplicate timestamp narration.

- Keyboard:
  - Transcript text remains selectable; Tab focuses actionable controls only.

- Reduced Motion:
  - Respect `prefersReducedMotion`: disable fade transitions; switch to instant updates.

---

#### Checklist

- [x] Add `TranscriptEntry.swift` model with `Role`, `id`, `text`, `timestamp`, `isStreaming`.
- [x] Introduce `entries: [TranscriptEntry]` in `FamiliarViewModel`.
- [x] On submit: append user + create streaming assistant entry.
- [x] Stream handling: coalesce and append to active assistant entry.
- [x] On completion: mark assistant entry `isStreaming = false`.
- [x] Create `TranscriptEntryView` with role styling, chips, tokens.
- [x] Swap `FamiliarWindow` transcript to `LazyVStack` of entries.
- [x] Implement bottom-anchor auto-scroll with 20pt threshold guard.
- [x] Constrain width to 680pt; keep line height stable (~24pt).
- [x] VoiceOver reads role + content + time naturally.
- [x] Reduced motion disables fade transitions.

---

#### Acceptance Criteria

- Role grouping: user and assistant entries render with distinct, token-driven surfaces.
- Stability: no line-height shifts or reflow jitter while streaming; auto-scroll sticks to bottom unless user scrolls up beyond ~20pt.
- Tokens: all spacing, radius, fonts, and colors use Familiar tokens (no hardcoded values).
- Accessibility: VoiceOver narration is clear; reduced motion respected.
- Performance: smooth scroll and animations at 60fps with 200+ streamed lines.

**References**:

- `docs/design/visual-improvements.md:125–141` (Transcript Grouping)
- `docs/design/aesthetic-system.md:563–693` (Tokens & Motion), `740–819` (Streaming constraints)

### 3.2 Enhanced Error/Loading Feedback

**Files**: New components `StatusBannerView.swift`, improve loading states

**Status**: In Progress

**Done**:
- [x] Added `StatusBannerView` with conversational summary + details disclosure
- [x] Integrated banner into `FamiliarWindow` for error display

**Next**:
- [ ] Optional success/info variants where applicable

**Reference**: visual-improvements.md:123-133

### 3.3 Approval Sheet Enhancements

**File**: `ApprovalSheet.swift`

**Goal**: Diff legibility, per-line backgrounds, line numbers

**Status**: In Progress

**Done**:
- [x] Per-line backgrounds for +/−
- [x] Monospaced, right-aligned line numbers

**Next**:
- [ ] Consider dimming metadata headers and emphasizing hunks

**Reference**: visual-improvements.md:155-165

### 3.4 Motion & Animation Polish

**Files**: All components

**Goal**: Apply Familiar spring consistently across all state changes

**Reference**: visual-improvements.md:260-298

### 3.5 Accessibility Sweep

**All files**

**Goal**: WCAG AA compliance, VoiceOver testing, keyboard navigation

**Reference**: visual-improvements.md:631-654

---

## Progress Tracking

### Phase 1 Complete! ✅ (Completed: September 30, 2025)

#### Phase 1.1: Design Tokens System ✅

- [x] Created Design/ directory
- [x] Implemented FamiliarSpacing.swift (8pt rhythm: xs:8, sm:16, md:24, lg:32, xl:48)
- [x] Implemented FamiliarRadius.swift (control:8pt, card:16pt)
- [x] Implemented FamiliarTypography.swift (title, heading, body, caption, mono)
- [x] Implemented FamiliarColor.swift (semantic colors)
- [x] Implemented FamiliarMotion.swift (The Familiar Spring)

#### Phase 1.2: Language Audit ✅

- [x] Updated ApprovalSheet.swift ("I can [action] for you", "Yes, do it", "Not right now")
- [x] Updated SettingsView.swift ("Check if it works", "Looks good")
- [x] FamiliarWindow.swift already conversational

#### Phase 1.3: Quick Wins ✅

- [x] Refined PromptTextEditor.swift (accent border, design tokens)
- [x] Added text labels to Send/Stop buttons
- [x] Created BreathingDotView.swift component
- [x] Applied FamiliarSpacing across all components
- [x] Replaced ProgressView with BreathingDot

#### Phase 1.4: The Familiar Spring ✅

- [x] Integrated .familiarInteractive animations in PromptTextEditor

**Build Status**: ✅ All changes compile successfully (1.95s build time)

### Phase 2 Complete! ✅ (Completed: September 30, 2025)

#### Phase 2.1-2.4: AI-Powered Zero State ✅

- [x] Created ZeroStateView.swift (76 lines, 3 loading states)
- [x] Created SuggestionCard.swift (38 lines, hover effects)
- [x] Created ShimmerCard.swift (25 lines, loading placeholders)
- [x] Implemented backend zero_state.py (104 lines, Claude SDK integration)
- [x] Added /zero-state/suggestions endpoint to api.py
- [x] Integrated into FamiliarWindow.swift (ZStack pattern)
- [x] Added fetchZeroStateSuggestions() to FamiliarViewModel
- [x] Added fetchZeroStateSuggestions() to SidecarClient
- [x] AI-powered suggestions with time/day context
- [x] Graceful fallback on errors
- [x] Accessibility verified (VoiceOver, keyboard, reduced motion)
- [x] Design token compliance verified

**Build Status**: ✅ All changes compile successfully (1.26s build time)
**PR**: #13 (phase-2-zero-state-clean branch)

---

## Testing Checklist

After each component:

- [ ] Test in light mode
- [ ] Test in dark mode
- [ ] Test with reduced motion enabled
- [ ] Test with VoiceOver enabled
- [ ] Test keyboard-only navigation
- [ ] Test at minimum window size
- [ ] Test at maximum window size
- [ ] Profile animation performance (60fps target)

---

## Success Criteria

### Foundation Success

- All design tokens implemented and documented
- Zero hardcoded spacing/colors remain in UI code
- Familiar spring applied to all animations
- Language audit complete (no "Approve?" anywhere)
- Quick wins from visual-improvements.md shipped

### Zero State Success

- Beautiful welcome screen on empty transcript
- 4 contextual suggestions show on load
- Suggestions vary by time/day
- Click populates prompt field
- Instant hide on typing
- Smooth animations throughout
- Accessible via keyboard and VoiceOver

### The Ive Test

- Is it inevitable? (feels obvious in hindsight) ✓
- Is it essential? (nothing superfluous) ✓
- Does it show care? (attention to detail perceptible) ✓
- Is the design invisible? (user thinks about task, not UI) ✓

---

## Related Documents

### Essential Reading

- **aesthetic-system.md** - Core design philosophy (READ FIRST)
- **visual-improvements.md** - Implementation roadmap with quick wins
- **intelligent-zero-state.md** - Zero state specification
- **hidden-delights.md** - Easter eggs (integrate later)

### Future Work

- **agent-visualization.md** - 10-week project (parallel track)
- Zero state V2 with AI generation (after V1 ships)
- Hidden delights integration
- V27 Magic Mode (aspirational)

---

**Last Updated**: October 2, 2025
**Status**: ✅ Phase 1 Complete | ✅ Phase 2 Complete | 🚧 Phase 3 In Progress
**Current Task**: Phase 3.2 - Enhanced Error/Loading
