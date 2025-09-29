# Visual Improvements - Consolidated Plan

**Status**: 📋 PLANNED
**Consolidates**: visual-polish-plan.md, visual-polish-sprint-notes.md, polish-tooling.md

---

## Overview

This document consolidates all visual polish work for the Familiar app. The goal is to transform the current functional-but-ugly SwiftUI interface into a polished, professional experience that delights users while maintaining clarity and performance.

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

1. **Week 1**: Quick Wins #1-3 (Prompt, Buttons, Transcript)
2. **Week 2**: Quick Wins #4-7 (Status, Usage, Settings, Diff)
3. **Week 3**: Design Tokens + Component Card System
4. **Week 4**: Motion & Animation Polish
5. **Week 5**: Empty States + Success Confirmations
6. **Week 6**: Accessibility Sweep + Validation

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

## Notes for Future Developers

- **Don't Sacrifice Clarity**: Visual polish should enhance, not obscure information
- **Test on Multiple Displays**: Ensure colors work in light mode and dark mode
- **Profile Animations**: Canvas operations can be expensive; use Instruments
- **Iterate with Users**: Get feedback early on visual changes
- **Document Decisions**: Update this file when introducing new patterns

---

**Last Updated**: September 29, 2025
**Status**: 📋 Ready for sprint planning