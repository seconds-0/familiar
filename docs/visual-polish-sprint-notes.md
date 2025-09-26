# Familiar Visual Polish Sprint Notes

## Current Snapshot
- **Main Window** (`FamiliarView`)
  - Fixed 720×460 panel with glass material background and monospaced transcript.
  - Transcript, tool summary, usage totals, streaming indicator stacked before prompt composer.
  - Composer combines custom `PromptTextEditor` with icon-only send/stop buttons and instructional footer.
- **Prompt Text Editor**
  - Rounded material background with gray stroke, 4-line max without scrollbar.
  - Placeholder text duplicates preview handling; focus state managed via custom `NSTextView` bridge.
- **Usage & Tool Summaries**
  - Usage summary uses secondary/tertiary foreground styles only; no visual separation.
  - Tool summary shows status chip with default SF Symbol, white background (`.windowBackgroundColor`).
- **Settings**
  - Card-like sections stacked vertically; segmented picker for models, workspace path text field, toggle.
  - Primary CTAs: "Test Connection" (bordered) and "Save" (prominent) aligned right.
- **Approval Sheet**
  - 420pt wide modal with title, path label, diff/preview scroller, and three-button decision row.
  - Diff colors rely on `.green`/`.red` only; limited nuance for context lines.

## Rough Edges & Observations
- Icon-only send/stop buttons lack textual affordance; contrast vs glass background unclear.
- Transcript block can feel dense—no separation between runs, no timestamp or subtle dividers.
- Tool summary background uses window color, which can clash in dark mode and feels flatter than main surface.
- Usage summary typography is small and uniform; hierarchy between session vs last session data is subtle.
- Settings view spacing is generous but sections visually blur together; toggles and secondary actions read as plain.
- Approval sheet call-to-action order (Deny left, Allow once right) is conventional, but secondary "Always Allow" lacks visual hierarchy; diff preview lacks contextual padding and fails to highlight file metadata beyond path label.
- Streaming indicator uses footnote text; could benefit from status pill and short microcopy library.
- No dedicated empty states for transcript or settings success messages beyond plain secondary text.

## Component Analysis

### FamiliarView (Main Window)
- **Layout Rhythm**: Vertical stack relies on 12pt gaps; lacks sectional separation between transcript, summaries, and composer. Consider cards or rule dividers to guide focus.
- **Hierarchy**: Transcript text matches prompt font, making results and user input blend. Add role-based styling (e.g., tinted headers or alternating backgrounds).
- **Interactions**: Send button uses `buttonStyle(.borderedProminent)` but only an icon—add tooltip exists yet microcopy or label would improve clarity. Streaming state could animate icon or swap to progress chip.

### PromptTextEditor
- **Visual Weight**: `Color.gray.opacity(0.25)` stroke reads low-contrast on glass; explore dynamic stroke matching accent/dark mode.
- **Placeholder vs Preview**: Both share identical styling, which may confuse users; differentiate preview text (e.g., italic or tinted background).
- **Keyboard Cues**: Footer hint uses single line; consider grouping key commands into pill tags for scannability.

### ToolSummaryView
- **Background**: `.windowBackgroundColor` may be too bright in light mode and muddy in dark; switch to semantic material with subtle border.
- **Status Indicator**: Use accent-accented pill with text (e.g., "Applied", "Error") rather than icon + sentence for faster parsing.
- **Snippet Scroll**: No padding inside scroll view; add inner padding and background to improve legibility.

### UsageSummaryView
- **Typography**: Session vs last session both use small fonts; elevate "Session" line to callout/headline and treat "Last" as secondary caption.
- **Iconography**: `sparkles` and `clock.arrow.circlepath` are playful but might need alignment with brand tone; optionally add tinted circles.
- **Data Density**: Introduce grid or tokens (e.g., chips for tokens/cost) to break monotony.

### SettingsView
- **Card Structure**: Each section could adopt card backgrounds or separators to build scannability. Currently, single column with borderless toggles feels sparse.
- **Form Controls**: Rely on `.roundedBorder` text fields, which can look iOS-like; consider macOS-style bordered fields or custom styling for brand alignment.
- **Feedback States**: Status message uses plain text; upgrade to banner component with icon and background tint.

### ApprovalSheet
- **Header**: Bold title lacks supporting subtitle (e.g., tool description). Add metadata row for source path, tool summary.
- **Diff**: Monospaced chunk but no color-coded background. Introduce inline backgrounds for additions/deletions for easier scanning.
- **Buttons**: Add descriptive subtitles or adjust button order to emphasize safest option; consider icons for allow/deny for quick recognition.

### Microcopy & States
- Loading microcopy rotates but no visual anchor; add branded spark animation or status pill.
- Error label in main window uses `.foregroundStyle(.red)` with default icon; consider inline banner treatment to avoid layout shift.

## Assets & Utilities
- Screenshot/visual diff scripts ready under `scripts/visual-polish/`.
- CLI stack: ffmpeg, gifsicle, ImageMagick, xcbeautify, svgo, shot-scraper, swiftformat, swiftlint.

## Open Questions
- Confirm desired hierarchy for usage stats (e.g., per-run vs per-session).
- Decide whether to introduce brand accent beyond system blue.
- Clarify tone for loading/error copy (keep whimsical vs. dial back?).
