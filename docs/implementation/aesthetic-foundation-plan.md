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
- [ ] Implement FamiliarMotion.swift
- [ ] Add unit tests for token values
- [ ] Document usage in code comments

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
- [ ] Audit ApprovalSheet.swift button text
- [ ] Update SettingsView.swift labels
- [ ] Review FamiliarWindow.swift status messages
- [ ] Update error messages in FamiliarViewModel.swift
- [ ] Check ToolSummaryView.swift for corporate language
- [ ] Test all text changes in light and dark mode
- [ ] Verify VoiceOver reads naturally

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
- Increase corner radius to 12pt (using `FamiliarRadius.control`)
- Use `FamiliarSpacing` for padding

**Checklist**:
- [ ] Update border styling
- [ ] Add inner shadow
- [ ] Style preview text
- [ ] Apply corner radius from tokens
- [ ] Apply spacing from tokens
- [ ] Test in light/dark mode

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
- [ ] Add text labels to buttons
- [ ] Apply button styles
- [ ] Set distinct colors
- [ ] Verify 44pt tap targets
- [ ] Test accessibility with VoiceOver
- [ ] Add keyboard shortcuts hints

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
- [ ] Create BreathingDotView.swift
- [ ] Implement breathing animation
- [ ] Replace spinner in FamiliarWindow
- [ ] Position next to prompt field
- [ ] Test animation with reduced motion preference
- [ ] Verify 60fps performance

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
- [ ] Audit all padding/spacing in FamiliarWindow.swift
- [ ] Update ApprovalSheet.swift spacing
- [ ] Apply tokens to SettingsView.swift
- [ ] Fix ToolSummaryView.swift layout
- [ ] Update UsageSummaryView.swift spacing
- [ ] Visual regression test all screens
- [ ] Verify layouts at different window sizes

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

**File**: `FamiliarWindow.swift`

**Goal**: Create `TranscriptEntryView` component with alternating backgrounds

**Reference**: visual-improvements.md:111-119

### 3.2 Enhanced Error/Loading Feedback

**Files**: New components `StatusBannerView.swift`, improve loading states

**Reference**: visual-improvements.md:123-133

### 3.3 Approval Sheet Enhancements

**File**: `ApprovalSheet.swift`

**Goal**: Diff legibility, per-line backgrounds, line numbers

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

### Week 1 Goals
- [ ] Design token system complete
- [ ] Language audit complete
- [ ] Prompt composer refinement done
- [ ] Send/Stop buttons improved

### Week 2 Goals
- [ ] Breathing dot implemented
- [ ] Consistent spacing applied
- [ ] Familiar spring integrated everywhere
- [ ] Foundation complete ✅

### Week 3 Goals
- [ ] ZeroStateView implemented
- [ ] Suggestion generator working
- [ ] Integration with FamiliarWindow complete
- [ ] Zero state V1 shipped ✅

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

**Last Updated**: September 30, 2025
**Status**: 🚧 IN PROGRESS
**Current Task**: Phase 1.1 - Design Tokens System
