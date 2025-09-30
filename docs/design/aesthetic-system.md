# Familiar Design System — Clarity, Intelligence, Joy

Status: Active

This document defines the aesthetic and interaction system for Familiar: a universal AI assistant that makes any intent feel achievable. The design philosophy is **sophisticated simplicity with hidden depth** — accessible to everyone on the surface, rewarding for those who explore.

---

## Core Philosophy

Familiar is designed for **everyone**: from grandma organizing desktop files to developers debugging complex systems. The interface must be:

- **Immediately understandable**: No learning curve, no technical jargon
- **Joyful to use**: Interactions feel delightful, not transactional
- **Respectful of attention**: Present when invoked, absent otherwise
- **Rewarding to explore**: Hidden depth for curious users

**The guiding principle**: Make the complex feel simple. Code, AI, technical operations — all invisible. The user sees problems solved, not implementation details.

---

## Design Principles

### 1. Clarity Over Decoration
- Every visual element serves communication, not ornamentation
- Information hierarchy is immediately apparent
- No aesthetic choices that obscure function
- "Can grandma understand this?" is the litmus test

### 2. Joy Through Interaction
- Delight comes from how it works, not how it looks
- Micro-interactions feel alive and responsive
- Success moments are celebrated subtly
- The experience itself brings satisfaction

### 3. Human Language
- Write like you're talking to a friend
- "Is that ok?" not "Approve?"
- "I can help with that" not "Processing request"
- Precise but warm, clear but personable

### 4. Mystery Through Discovery
- Hidden features reward exploration
- Easter eggs for power users and curious minds
- Depth is discoverable, not presented
- You can use Familiar forever and still find surprises

### 5. Function Over Ornamentation
- Beauty through purposeful design, not decoration
- Every animation communicates state
- Sound is informative and iconic
- Motion has meaning

---

## Visual System

### Palette: Refined Neutrals + One Distinctive Touch

**Foundation** (System Colors):
- Background: macOS native window background
- Surface elevated: Slightly lighter/darker depending on mode
- Text primary: System label color
- Text secondary: System secondary label

**Distinctive Accent**:
- Primary accent: System accent (respects user preference) OR
- Custom signature color: To be defined (sophisticated, not loud)
- Used sparingly: CTAs, active states, success confirmations

**Semantic Colors**:
- Success: Forest green `#2D7A4F`
- Warning: Warm amber `#F59E0B`
- Error: Muted crimson `#DC2626`
- Info: Calm blue `#3B82F6`

**Dark Mode First**: Design for dark mode, ensure light mode works beautifully.

### Typography: System Native

**Font**: San Francisco (macOS system font)
- Title: `.title2`, weight `.semibold`
- Heading: `.headline`, weight `.medium`
- Body: `.body`, weight `.regular`
- Caption: `.caption`, weight `.regular`
- Mono: `.body`, design `.monospaced` (for paths, code when visible)

**Hierarchy**:
- Use size, weight, and color to establish importance
- Body text 100% opacity, secondary 70%, tertiary 50%
- Never sacrifice legibility for aesthetic

### Spacing: Consistent Scale

Based on 4pt grid:
- `xxs: 2pt` (tight inline)
- `xs: 4pt` (related elements)
- `sm: 8pt` (component internal)
- `md: 12pt` (between components)
- `lg: 16pt` (section spacing)
- `xl: 24pt` (major sections)
- `xxl: 32pt` (page regions)

**Breathing room**: Generous padding makes interface feel calm, not cramped.

### Geometry: Soft Corners, Clear Boundaries

- Standard corner radius: `12pt` (modern, friendly)
- Small elements: `8pt`
- Large panels: `16pt`
- Circular elements: Always perfect circles
- Consistent alignment: Left-aligned text, centered CTAs

### Iconography: SF Symbols

- Use SF Symbols for consistency with macOS
- Weight matches text weight in context
- Size matches adjacent text
- No custom icons unless absolutely necessary

---

## Motion & Animation

### Principles

- **Purposeful**: Every animation communicates state change
- **Fast**: 0.2-0.3s for most transitions, never > 0.5s
- **Natural**: Spring physics for organic feel
- **Accessible**: Respect `prefersReducedMotion`

### Animation Library

```swift
// Familiar standard animations
.spring(response: 0.3, dampingFraction: 0.7) // Default
.easeOut(duration: 0.25) // Exit animations
.easeInOut(duration: 0.2) // State changes
```

### Key Interactions

**Send Button**:
- Press: Scale to 0.95
- Release: Spring back to 1.0
- Success: Brief pulse (1.05 → 1.0)

**Approval Sheet**:
- Entrance: Slide up with ease-out + backdrop fade
- Exit: Slide down with ease-in
- Contents delay 0.1s for polish

**Status Changes**:
- Fade between states (0.2s)
- Color transitions smooth (0.3s)
- No jarring jumps

**Loading**:
- Fade in spinner after 0.3s (don't show for fast ops)
- Continuous rotation
- Fade out with scale-down (0.9)

---

## Sound Design

### Philosophy: Non-Distracting by Default

Following Ive's principle: most interactions should be **silent**. Sound is punctuation, not narration.

**Sound serves two purposes**:
1. **Voice output**: Natural for voice assistant (user chooses to enable voice)
2. **Critical feedback**: Rare, purposeful confirmation when needed

**Not for**:
- UI affordance sounds (clicks, whooshes, etc.)
- Constant audio feedback
- Decoration or atmosphere

### Voice Output (Primary Sound Use)

**When voice mode is enabled**:
- Familiar speaks responses (natural TTS)
- This is the **primary sound experience**
- User explicitly chose voice interaction
- Volume controlled by system

**See `voice-assistant.md` for full specification**

### UI Sounds (Minimal, Optional)

**Default: OFF** (silent confidence)

**Optional confirmation sound** (if user enables):
- One subtle tone for task completion
- Brief (< 500ms)
- Purposeful, not decorative
- System sound or minimal custom sound

**Examples of when NOT to use sound**:
- Button presses
- Text input
- Window opening/closing
- Status changes
- Most interactions

**Examples of when sound COULD be used** (opt-in):
- Major task completion (organized 100 files)
- Error that requires attention
- Background task finished (if user left app)

### Implementation

```swift
enum FamiliarSound {
    case completion // Only if user enables UI sounds
    case error // Only if user enables UI sounds

    var isEnabled: Bool {
        UserDefaults.standard.bool(forKey: "enableUISounds") // Default: false
    }

    func play() {
        guard isEnabled else { return }
        // Brief, purposeful system sound
        NSSound(named: .pop)?.play()
    }
}
```

**Settings**:
- "Enable UI sounds" toggle (default: off)
- "Voice output" toggle (default: on if using voice mode)
- System volume controls both

**The principle**: Ive's iPhone was remarkably quiet. Most interactions were silent. Sound was rare and purposeful.

---

## Voice Interface (Primary Mode)

Voice is not an add-on — it's the **primary interface** for Familiar.

### Why Voice First

- Universal accessibility (grandma doesn't type commands)
- Natural intent expression (say what you want)
- Invisible technology (no UI complexity)
- Fast interaction (speak → done)

### Voice UX Principles

**Conversational, Not Robotic**:
- "Is that ok?" not "Confirm action?"
- Natural back-and-forth dialogue
- Can interrupt and correct
- Forgiving of imprecise language

**Clear Feedback**:
- Visual indicator when listening (pulsing icon)
- Transcription shown ("I heard: ...")
- Can correct misunderstandings
- Voice output optional (text always available)

**Privacy First**:
- Transcription local or OpenAI Whisper (user choice)
- Voice never stored
- Clear when microphone is active
- Can disable voice entirely

### Voice + Visual Harmony

- Transcript shows conversation visually
- Technical details collapsed by default
- Voice says outcomes, screen shows details if needed
- Works perfectly with voice-only OR voice+visual

**See `docs/future/voice-assistant.md` for full specification.**

---

## Language & Tone

### Writing Guidelines

**Do**:
- "I can organize your desktop for you"
- "Is that ok?"
- "I found 47 photos from this weekend"
- "Done! Your files are organized"
- "Hmm, I can't access that file"

**Don't**:
- "Familiar wants to execute command"
- "Approve?"
- "Operation completed successfully"
- "Error: Permission denied [Errno 13]"

### Personality

- **Helpful friend**, not corporate assistant
- **Confident but humble**: "I can do that" not "I will do that"
- **Warm but precise**: Friendly without being cutesy
- **Respectful**: Asks permission, never assumes
- **Clear**: Says what it means, no jargon

**Never**:
- Overly enthusiastic ("Wow! Amazing!")
- Corporate speak ("Your request has been processed")
- Technical jargon unless user is technical
- Cutesy mascot behavior
- Mystical language (save for easter eggs)

---

## Permission & Approval System

### Philosophy

Permissions exist to build trust, not satisfy legal requirements.

### Approval Language

**Template**:
```
I can [action] for you:
• [Specific detail 1]
• [Specific detail 2]
• [Specific detail 3]

Is that ok?

[Show me how ▼]  [Not right now]  [Yes, do it]
```

**Example**:
```
I can organize your desktop for you:
• Put your 47 images into an "Images" folder
• Put your 23 PDFs into a "Documents" folder
• Put your 8 videos into a "Videos" folder

Is that ok?

[Show me how ▼]  [Not right now]  [Yes, do it]
```

### Button Language

- "Yes, do it" / "Sounds good" / "Go ahead" (not "Approve")
- "Not right now" / "No thanks" (not "Deny" or "Cancel")
- "Show me how" (not "Show details")

### Trust Through Clarity

- Say specifically what will happen
- Use real numbers (47 images, not "files")
- Explain consequences if not obvious
- Make approval feel collaborative, not bureaucratic

---

## Technical Abstraction Layers

### Layer 1: Human Outcomes (Default)
**What median users see**:
- Problems stated in natural language
- Solutions described in terms of outcomes
- Approvals focused on what will happen
- Results shown as achievements

**Example**: "Organized 47 images into folders"

### Layer 2: How It Works (Collapsed)
**For curious users who expand**:
- "I'll write a script to organize the files"
- Mention of tools/approaches used
- Still outcome-focused, slightly more detail

**Example**: "I used a Python script to sort files by type"

### Layer 3: Technical Details (Hidden)
**For developers who want everything**:
- Actual code blocks
- File paths and diffs
- Command outputs
- Error messages and stack traces

**Example**: Full Python script, file operations log, error details

**Users choose their depth**. Most stay at Layer 1. That's correct.

---

## Hidden Delights

### Philosophy

Sophisticated simplicity on the surface, discoverable magic beneath.

### Categories of Hidden Depth

**1. Easter Eggs**: Konami codes, hidden messages, midnight mode
**2. Power User Features**: Keyboard shortcuts, advanced commands, debugging
**3. Lore & Personality**: About screen, credits, development story
**4. Achievement Tracking**: Internal milestones (not surfaced yet)
**5. V27 Magic Mode**: Full hermetic aesthetic (far future stretch goal)

**See `docs/design/hidden-delights.md` for complete catalog.**

### Guidelines for Hidden Features

- Must never interfere with primary functionality
- Should delight discoverers without confusing everyone else
- Can reference mystical concepts (as easter eggs)
- Reward curiosity and exploration
- Balance surprise with usability

---

## Accessibility

### Non-Negotiable Standards

- WCAG AA minimum (AAA preferred)
- VoiceOver fully supported
- Keyboard navigation complete
- High contrast mode respected
- Reduced motion honored
- Minimum 44pt touch targets
- Color never sole information carrier

### Testing Requirements

- Enable VoiceOver: Navigate entire app
- Enable Reduced Motion: Verify animations disabled
- High Contrast: Verify legibility
- Keyboard only: Complete all tasks
- Various display sizes: Maintain usability

**Accessibility is not optional. It's how we ensure universality.**

---

## Platform Integration

### macOS Native

- Respect system preferences (accent color, dark mode, motion)
- Use native controls where possible
- Follow HIG for standard interactions
- Feel at home on Mac
- Consider iOS/iPadOS future (but not yet)

### Window Behavior

- Non-activating summon (doesn't steal focus from other apps)
- Dismisses on focus loss (configurable)
- Remembers size/position
- Respects multiple displays
- Keyboard shortcuts follow Mac conventions

---

## The Distinctive Element

Every memorable design has **one thing** that makes it recognizable. For Familiar:

### Primary: Signature Motion ⭐

**The "Familiar Feel"** — consistent spring animation across all interactions:

```swift
// The Familiar spring
extension Animation {
    static let familiar = Animation.spring(
        response: 0.3,
        dampingFraction: 0.7
    )
}
```

**Why motion**:
- Universal (everyone experiences it)
- Ive-like (iPhone's fluid animations defined the brand)
- No permissions required
- Works in all contexts (quiet meetings, voice mode, etc.)
- Accessible (can be reduced but still feels consistent)
- Testable in 1-2 week prototype

**Applied consistently**:
- Button presses
- Sheet presentations
- Status transitions
- Success confirmations
- All UI state changes

**The result**: Familiar feels **alive and responsive** in a recognizable way. Users might not consciously notice, but they feel it.

### Secondary Considerations

**Voice Personality**:
- Warm, helpful tone
- "Is that ok?" language
- Natural conversation flow
- This is part of the experience, not decoration

**Inline Approvals**:
- Everyday actions don't interrupt flow
- Sheets reserved for consequential decisions
- Trust through clarity, not ceremony

**System Integration**:
- Feels native to macOS
- Respects system preferences
- Nothing feels "foreign"

**The key**: Motion is the signature. Everything else is refined, clear, and invisible.

---

## Design Tokens (Canonical Values)

These values are **locked** to ensure consistency. Deviation requires justification.

### Spacing (8pt Rhythm)

```swift
enum FamiliarSpacing {
    static let xs: CGFloat = 8    // Tight inline elements
    static let sm: CGFloat = 16   // Related components
    static let md: CGFloat = 24   // Component groups
    static let lg: CGFloat = 32   // Sections
    static let xl: CGFloat = 48   // Major regions
}
```

**Grid**: All layouts snap to 8pt grid

### Corner Radius

```swift
enum FamiliarRadius {
    static let control: CGFloat = 8   // Buttons, fields, small UI
    static let card: CGFloat = 16     // Panels, sheets, containers
}
```

### Typography

**Font**: SF Pro (macOS system font)

```swift
enum FamiliarTypography {
    static let title = Font.system(.title2, design: .default, weight: .semibold)
    static let heading = Font.system(.headline, design: .default, weight: .medium)
    static let body = Font.system(.body, design: .default, weight: .regular)
    static let caption = Font.system(.caption, design: .default, weight: .regular)
    static let mono = Font.system(.body, design: .monospaced, weight: .regular)
}
```

**Line spacing**: System default (1.2x for body text)

### Colors

**System semantic colors** (adapt to light/dark/high-contrast automatically):

```swift
enum FamiliarColor {
    // Foundation
    static let background = Color(nsColor: .windowBackgroundColor)
    static let surfaceElevated = Color(nsColor: .controlBackgroundColor)
    static let textPrimary = Color.primary
    static let textSecondary = Color.secondary

    // Semantic (system)
    static let success = Color.green
    static let warning = Color.orange
    static let error = Color.red
    static let info = Color.blue

    // Accent (only custom color)
    static let accent = Color.accentColor // System default OR custom
}
```

**Accent color options** (if custom):
- Deep Teal: `#008B8B`
- Warm Copper: `#B87333`
- Soft Lavender: `#9B8DBD`
- Forest Sage: `#87AE73`

**Decision**: Start with system accent. Consider custom only if testing shows it's more memorable.

### Shadow

**One recipe** for elevated surfaces:

```swift
enum FamiliarShadow {
    static func card(_ color: Color = .black) -> some View {
        shadow(
            color: color.opacity(0.12),
            radius: 16,
            x: 0,
            y: 4
        )
    }
}
```

### Motion

**Two durations, one spring**:

```swift
enum FamiliarMotion {
    // Durations
    static let interactive: TimeInterval = 0.2    // Button press, tap feedback
    static let contextual: TimeInterval = 0.25    // Sheet, overlay, status change

    // The Familiar Spring (signature)
    static let spring = Animation.spring(
        response: 0.3,
        dampingFraction: 0.7
    )

    // Convenience
    static var interactiveSpring: Animation {
        spring.speed(0.2 / 0.3) // Scale to match duration
    }

    static var contextualSpring: Animation {
        spring.speed(0.25 / 0.3)
    }
}
```

**Usage**:
```swift
// Interactive (buttons)
.animation(.interactiveSpring, value: isPressed)

// Contextual (sheets)
.animation(.contextualSpring, value: isPresented)
```

### Window Geometry

**Summon window specifications**:

```swift
enum FamiliarWindow {
    static let minSize = CGSize(width: 600, height: 400)
    static let preferredSize = CGSize(width: 720, height: 600)
    static let cornerRadius: CGFloat = 16
    static let padding: CGFloat = 24    // Interior padding
    static let shadowY: CGFloat = 4
    static let shadowBlur: CGFloat = 16
    static let shadowOpacity: Double = 0.12
}
```

### Progress Indication

**No spinner by default** — use subtle progress affordance:

```swift
enum FamiliarProgress {
    static let thresholdForSpinner: TimeInterval = 0.6  // Show spinner only after 600ms

    // Default: breathing dot
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
}
```

**Alternative**: Animated underline below prompt field

### Streaming Behavior (Zero Jitter)

**Transcript text constraints**:

```swift
enum FamiliarStreaming {
    static let lineHeight: CGFloat = 24        // Fixed, never reflows
    static let maxWidth: CGFloat = 680         // Prevents horizontal jump
    static let batchTokens: Int = 5            // Append in small batches, not single chars
    static let scrollThreshold: CGFloat = 20   // Pixels from bottom to maintain scroll
}
```

**Implementation rules**:
- Fixed `lineHeight` on Text views (never let SwiftUI reflow)
- Width-constrained container (prevent horizontal expansion)
- Batch token reveals (5 at a time, not character-by-character)
- Opacity fade-in for new content (don't pop in)
- Scroll sticks to bottom unless user scrolls up manually

---

## Default Stances (Decisions Made)

Document explicit defaults to eliminate interpretation:

### User Interface
- **Window style**: NSPanel, non-activating
- **Dismiss on focus loss**: Yes (configurable in settings)
- **Escape key behavior**: Dismisses window
- **Multi-display**: Opens on display with cursor

### Audio
- **UI sounds**: Off by default
- **Voice output**: On if user enables voice mode, off otherwise
- **Volume**: System controlled

### Voice
- **Transcription engine**: macOS native (on-device, private)
- **Alternative**: OpenAI Whisper (opt-in for better accuracy)
- **Voice output**: macOS NSSpeechSynthesizer by default
- **Alternative**: OpenAI TTS (opt-in for natural voice)

### Visual
- **Progress indicator**: Breathing dot (subtle)
- **Spinner threshold**: 600ms (rare, only for long operations)
- **Animations**: Full motion (respects system "reduce motion")
- **Accent color**: System default (blue) initially

### Interaction
- **Approvals**: Inline for common actions, sheets for rare/consequential
- **Keyboard shortcuts**: All standard Mac conventions
- **Focus behavior**: Text field auto-focused on open

### Technical
- **Model selection**: Sonnet 4.5 (claude.ai auth) or Haiku (API key)
- **Zero state suggestions**: AI-generated (V2+), static (V1)
- **Context gathering**: Minimal by default, opt-in for rich context

---

## Craft Checklist (Every PR)

Before merging, verify:

### Reduction
- [ ] Could anything be removed?
- [ ] Is every element necessary?
- [ ] Any redundant copy or UI?

### Friction
- [ ] Any unnecessary steps?
- [ ] Can user achieve goal faster?
- [ ] Any jarring transitions?

### Alignment
- [ ] Visually aligned to 8pt grid?
- [ ] Spacing uses design tokens?
- [ ] Radii consistent (8 or 16)?

### Latency
- [ ] Feels instant? (<100ms perceived)
- [ ] No blocking operations?
- [ ] Async where needed?

### Jitter
- [ ] Text stable during streaming?
- [ ] Layout doesn't reflow unexpectedly?
- [ ] Fixed line heights where needed?

### Dark Mode
- [ ] Tested in dark mode?
- [ ] Contrast sufficient?
- [ ] System colors used (not hex)?

### Accessibility
- [ ] VoiceOver tested?
- [ ] Keyboard navigation works?
- [ ] Reduced motion respected?

### Motion
- [ ] Uses `.familiar` spring?
- [ ] Duration matches tokens (200/250ms)?
- [ ] Purposeful, not decorative?

---

## Implementation Roadmap

### V1: Sophisticated Foundation (Current)
- Clean, accessible interface
- Human language throughout
- Smooth animations
- Voice input/output
- Technical abstraction (Layer 1 default)

### V2-V10: Refinement & Delight
- Polish micro-interactions
- Add hidden features gradually
- Refine signature element
- Improve voice personality
- Subtle easter eggs

### V27: Magic Mode (Aspirational)
**Stretch goal for fellow mystics**:
- Hidden toggle in advanced settings
- Overlays hermetic aesthetic
- Sigils, archetypes, mystical language
- Optional for those who seek it
- See `docs/design/hidden-delights.md` for specification

**V27 is cope that becomes real** — mysticism preserved, accessibility maintained.

---

## Success Criteria

### Immediate Understanding Test
Show Familiar to someone who's never seen it:
- Do they understand what it does? (< 10 seconds)
- Can they use it successfully? (< 30 seconds)
- Do they feel confident, not anxious?

### Joy Test
After using Familiar:
- Did the experience bring satisfaction?
- Would they choose to use it again?
- Did any moment delight them?

### Accessibility Test
- Can grandma use it? (voice especially)
- Can a developer use it? (with full power)
- Can someone with accessibility needs use it? (VoiceOver, keyboard, etc.)

### The Ive Test
Would Jony Ive approve?
- Is it inevitable? (feels obvious in hindsight)
- Is it essential? (nothing superfluous)
- Does it show care? (attention to detail perceptible)
- Is the design invisible? (user thinks about task, not UI)

---

## Related Documents

- **`voice-assistant.md`**: Full voice interface specification
- **`hidden-delights.md`**: Easter eggs and discoverable depth
- **`visual-improvements.md`**: Concrete UI polish tasks
- **`intelligent-zero-state.md`**: Smart suggestions system

---

## Open Questions

1. What should the "one distinctive element" be?
2. Should voice output be on by default or opt-in?
3. How do we balance power user features with simplicity?
4. When/how do users discover hidden delights?

---

*This document defines Familiar's soul: sophisticated, accessible, joyful, with mystery for those who seek it.*

**Last Updated**: September 30, 2025
**Status**: Active — guides all design decisions