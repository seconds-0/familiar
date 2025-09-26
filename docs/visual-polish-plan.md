# Familiar Visual Polish Plan

## Quick Wins (Sprint-Ready)
- **Refresh prompt composer chrome**
  - Swap gray stroke for semantic accent stroke that adapts to light/dark (`Color.accentColor.opacity(0.35)` + matched inner shadow).
  - Simplify placeholder hierarchy: italicize preview text, lighten default placeholder, ensure contrast on glass.
- **Add send/cancel button labels**
  - Convert icon-only buttons to text+icon capsules ("Send", "Stop") or add mini labels beneath icons for clarity.
  - Provide consistent hover states and ensure tooltips match action copy.
- **Introduce transcript grouping**
  - Insert subtle section dividers or timestamp chips between user and Familiar messages; alternate background tint for AI responses.
- **Elevate error/loading feedback**
  - Replace inline red `Label` with rounded banner containing icon, copy, and optional "View details" link.
  - Transform streaming indicator into status pill (progress spinner + short message) anchored above composer.
- **Usage summary hierarchy**
  - Promote "Session" line to callout with accent bullet; render last-session data as muted caption within same card.
- **Settings status banner**
  - Wrap status text in card with icon, tinted background (green/orange) and optional action link.
- **Approval sheet diff legibility**
  - Add inner padding + background color for diff lines (`green.opacity(0.15)` additions, `red.opacity(0.15)` removals); introduce monospace size bump for readability.
- **Scripts & documentation updates**
  - Capture before/after visuals using `shot-scraper` + `screenshot-compare.sh`; document results in sprint notes.

## Deeper Pass (Schedule After Quick Wins)
- **Design token extraction**
  - Define typography scale (Title, Heading, Body, Caption, Mono) in shared token file for reuse.
  - Establish semantic color roles (Surface, SurfaceElevated, AccentSuccess/Warning) and adopt across views.
- **Component card system**
  - Create reusable card style for transcript entries, summaries, settings sections, and modals with consistent padding, radius, and shadows.
- **Brand accent development**
  - Explore signature accent color + supporting palette; validate contrast via `color-contrast-checker` script.
- **Motion polish**
  - Prototype micro-interactions (send button press, loading transitions, approval sheet entrance) using Figma Smart Animate or Principle; document timing specs.
- **Empty & success states**
  - Design dedicated visuals for initial empty transcript, post-command success confirmation, and settings saved state.
- **Tool summary redesign**
  - Introduce icon row with colored status pill, code snippet card with header, and optional CTA for copying patch.
- **Accessibility sweep**
  - Run `accessibility-check.sh` against dev build; address focus order, label clarity, contrast adjustments uncovered.

## Dependencies & Notes
- Token work depends on agreeing to palette direction; schedule mini workshop before implementation.
- Motion prototypes require recorded clips for engineering handoff (store in `demo-gifs/`).
- Keep track of decisions and assets in `docs/visual-polish-sprint-notes.md` for future contributors.

## Implementation Notes
- **Main window updates** (`FamiliarView`)
  - Add section dividers or `GroupBox` wrappers around transcript history and summaries; update send/stop buttons inside `HStack` (lines 91-116) to use `Label("Send", systemImage: ...)` and `.controlSize(.large)` for visual weight.
  - Introduce new `TranscriptEntryView` to alternate background colors and include timestamps sourced from view model if available.
- **Prompt composer** (`PromptTextEditor`)
  - Replace fixed gray stroke (lines 48-50) with new semantic `Color` defined in shared style file; apply `.shadow(color: .black.opacity(0.1), radius: 6, y: 2)` for depth.
  - Differentiate preview text by applying `.italic()` and `foregroundStyle(.quaternary)` while keeping placeholder as `.secondary`.
- **Tool summary card** (`ToolSummaryView`)
  - Swap background fill (line 43) for `Material.ultraThin` or custom brand surface; wrap snippet scroll view in padded container with `ScrollViewReader` for top alignment.
- **Usage summary** (`UsageSummaryView`)
  - Convert outer `VStack` into `Label` rows with accent-leading dots; format currency via shared formatter to avoid repeated instantiation.
- **Settings view** (`SettingsView`)
  - Introduce `SectionCard` component with consistent padding and background; apply to credentials/model/workspace/automation groups.
  - Replace status text block with `BannerView` (new view) offering icon + tinted background; triggered in existing `statusMessage` binding.
- **Approval sheet** (`ApprovalSheet` & `DiffPreviewView`)
  - Create custom `DiffLineView` applying per-line background colors and monospace width adjustments; include top metadata row summarizing tool purpose.
  - Adjust button row spacing; add `.controlSize(.large)` for primary action and `.keyboardShortcut(.defaultAction)` for Allow Once.
