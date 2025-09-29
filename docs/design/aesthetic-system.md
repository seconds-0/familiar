# Familiar Aesthetic Experience — Technology × Hermetic Magic

Status: Draft

This document specifies a cohesive aesthetic and interaction system for Familiar that fuses precise computation with hermetic mysticism. It covers desktop (current) and an aspirational mobile paradigm. All magical ornamentation must correspond to real system state or user intent. No cutesy mascots; the tone is solemn, potent, and benevolent.

---

## Goals

- Make execution feel like ritual: summoning, implements, seals, bindings.
- Preserve speed and clarity; animations and sound are informative, never gratuitous.
- Surface trust and control through formal approvals (“oaths” with seals).
- Ensure every visual maps to a measurable, testable signal from the system.

---

## Principles

- Functional Magic: every flourish reveals process, cost, or risk.
- Deterministic Wonder: same inputs → same sigils/behaviors; no random noise.
- Respect for Performance: degrade gracefully; user can disable enchantments.
- Accessibility First: reduced motion, high contrast, mute by default.
- Taste: instruments, diagrams, seals; no faces or mascots.

---

## Visual System

### Materials & Palette

- Obsidian (background): `#0B0C10`
- Brass (lines/accents): `#B08D57`
- Parchment (panels): `#F4EDE1`
- Verdigris (secondary): `#3A7863`
- Aura States:
  - Spawning: Cornflower Blue `#6495ED`
  - Active: Golden Amber `#FFB000`
  - Waiting: Soft Purple `#9370DB`
  - Success: Forest Green `#228B22`
  - Blocked/Error: Crimson `#DC143C`

### Geometry & Iconography

- Circles, radial grids, isometric diagrams; sacred ratios for spacing.
- Implements (archetypes):
  - Scry (search/fetch/analyze): lens/scrying dish
  - Transmute (write/refactor): alembic/crucible
  - Invoke (shell/process): lightning apparatus
  - Bind (context/memory/git): cord/knots/seal
  - Banish (kill/revert/cleanup): imploding smoke/ban symbol

### Typography

- Body: system San Francisco / Inter for clarity.
- Labels: narrow small-caps styling; no faux grunge.

---

## Motion & Feedback

- Aura: panel border “breathes” at 2s during Active; settles to Success; pulses for Error/Waiting.
- Token Flow: faint ink stream behind assistant text; opacity mapped to tokens/sec.
- Implements: instrument tiles animate per state (spawn/active/wait/success/error).
- Execution Filament: subtle light trace from prompt to target path on successful write.

### Sound & Haptics

- Palette: glass chime (spawn), quill scratch (diff preview), seal press (approval), soft exhale (cancel).
- Dynamics: tie volume to operation weight; muted by default.
- Haptics (desktop trackpad / gamepad optional): click on seal; pulse on first tokens.

---

## Ritualized Approvals (Seal & Oath)

- Approval panel is a parchment card with a deterministic “path sigil.”
- Allow Once: press-and-hold ring fills; release stamps the seal.
- Always Allow: secondary concentric ring; mints rule to Oath Ledger (audit list).
- Diff as Marginalia: red/green runes in the left gutter; chunk headers as folio marks.

---

## Deterministic Sigils (Spec)

- Purpose: visual anchor for actions, paths, and sessions; consistent and verifiable.
- Seed: `SHA1(session_id | prompt | canonical_path? | tool_name)` → take first 8 bytes.
- Rendering:
  - Radial glyph with 8 axes (archetypes). Seed bits map to polygon vertices and orbiting points.
  - Stroke count capped (<= 24) for legibility; no randomness; deterministic.
  - Surfaces: watermark in transcript header, approval seal, menu bar state.

---

## System Truth → Aesthetic Mapping

- `assistant_text` SSE chunk rate → token flow opacity/speed.
- `tool_use` event → spawn instrument tile with archetype glyph + one-line mystical summary.
- `permission_request` → open Seal & Oath with sigil, diff/preview, and press-to-seal affordances.
- `tool_result` → stamped seal; show snippet as “extracted scroll” + path.
- Usage/Cost → “Residuum” line at bottom (tokens and currency), never prominent.

---

## Desktop Surfaces (macOS)

### Summon Window

- Non-activating centered panel with thin binding circle; prompt field is the “incantation.”
- Background `Canvas`: aura states keyed to streaming and last event type.

### Agentarium (Right Sidebar)

- Instrument tiles for each sub-process (archetype). Compact by default; expands on hover.

### Sanctum Mode (Full-Screen Work)

- Reduced chrome; black background with brass linework; optional for long-running tasks.

### Oath Ledger (Settings)

- Human-readable list of Always Allow rules with date minted; revoke at will.

---

## Implementation Plan (Repo Integration)

### Backend: `backend/src/palette_sidecar/claude_service.py`

- Emit archetype: map `tool_name` → `scry|transmute|invoke|bind|banish` in PreToolUse hook.
- Emit `sigilSeed`: SHA1 of `session_id|prompt|path|tool_name` (first 8 bytes, hex) on `permission_request`, `tool_use`, `tool_result`.
- Emit `phase` hints: `thinking|delegating|executing|summarising` inferred from hook sequence.
- Emit `tokenRate`: rolling tokens/sec in `assistant_text` at ~1Hz.

### SwiftUI: `apps/mac/FamiliarApp`

- FamiliarWindow: add `Canvas` aura background driven by view model state.
- New `SpellSidebarView`: instrument tiles for archetypes; driven by `tool_use`/`tool_result` events.
- ApprovalSheet: 
  - Replace buttons with press-and-hold “stamp” ring; secondary ring for Always Allow.
  - Render sigil via deterministic `Canvas` from `sigilSeed`.
- ToolSummaryView: add stamped seal and archetype glyph; keep current snippet and content.
- AppState/Settings: add toggles for Enchantments (motion, sound), Sanctum Mode, and mute.

### Telemetry & Safety

- No PII in sigil seeds; only path (canonical) and prompt text hash.
- Oath Ledger persisted via existing settings; expose list and revoke.

---

## Accessibility & Performance

- Reduced Motion: static sigils and auras; disable token flow.
- High Contrast: switch to monochrome brass/white; thicker strokes.
- Audio Mute by Default: granular toggles; brief auditory icons only.
- Frame Budget: limit animations to 60fps; pause off-screen; cap shader cost.

---

## Roadmap

### Quick Wins (1–2 weeks)

- Aura states in FamiliarWindow; map to existing loading states.
- Press-and-hold stamp on ApprovalSheet (Allow Once / Always Allow → `remember=true`).
- Deterministic sigil renderer (Canvas) with hash seed.
- MVP Agentarium: 3 archetypes lit by `tool_use`/`tool_result`.

### Next Sprint (2–4 weeks)

- Token-flow effect behind transcript (Canvas/Metal fallback).
- Execution filament animation between prompt and path on `tool_result`.
- Menu bar icon state machine reflecting `phase`.
- Oath Ledger view in Settings with revoke.

### Later (4–8 weeks)

- Sanctum Mode full-screen scene.
- Thematic tints (“planetary hours,” opt-in).
- Ambient sound palette with dynamic scaling.

---

## Personalization & Style Controls (Future)

- Familiar Style: users choose a tone pack and animation intensity to match preference.
  - Tone Packs: Direct, Mystical (default), Formal, Casual.
  - Intensity: Motion (Off/Low/Standard), Sound (Mute/Quiet/Normal), Mysticism (0–3).
  - Verbosity: Terse / Standard / Explanatory (caps at one sentence for narration).
- Inline Attunement: quick “More direct / More mystical” actions influence subsequent narration.
- Determinism: visual design remains consistent; only wording and intensity vary.
- Settings Storage: persisted in sidecar settings (future fields) and respected across sessions.

Acceptance (personalization):

- V1: single opinionated mystical style with accessibility toggles.
- V2+: add Style panel controls and inline attunement; maintain performance and clarity.

---

## Aspirational Mobile Paradigm (Far Future)

Vision: a voice-first familiar that lives ambiently on the device, rendering actions as rituals within strict OS constraints. Avoid novelty UI for its own sake; prioritize clarity and subtle magic.

### Mobile Surfaces

- Summon Orb: floating invocation view (iOS: overlay sheet; Android: bubble) that appears on top of current context within OS rules.
- Live Activities / Dynamic Island (iOS): display ritual progress (instrument glyph + aura) with compact updates.
- Notifications as Rituals: actionable cards with seals for approval (biometric confirm = “oath binding”).
- Ledger View: in-app list of past rituals, sigils, and outcomes; revoke Always Allow rules.

### Interaction Model

- Voice Incantations: wake phrase or tap-to-summon; transcript animates with token flow dots.
- Implements Shelf: horizontally scrolling instrument tiles; each shows state and minimal copy.
- Approvals: FaceID/TouchID confirms “seal” with haptic click; Always Allow requires a second confirm.

### Motion, Sound, Haptics (Mobile)

- Haptics Engine: map phases to short patterns (start, wait, success, error).
- Audio: tiny auditory icons, respect system mute.
- Auras: subtle gradient pulses; respect Reduced Motion.

### Constraints & Safety

- OS Compliance: no persistent overlays beyond platform allowances; Live Activities over custom hacks.
- Privacy: no microphone/camera without explicit intent; on-device where possible.
- Determinism: mobile sigils use same seed spec; cross-device consistency.

### Technical Notes (Aspirational)

- Transport: WebSocket/SSE to sidecar-equivalent; batched updates for battery.
- State: local cache of ritual states; recover/resume after app reclaim.
- Hardware Surfaces: Dynamic Island, lock screen widgets, Android bubbles/tiles as “ritual frames.”

---

## Open Questions

- How much user control over aesthetic intensity (themes vs. a single opinionated theme)?
- Should model/cost (“Residuum”) be visible by default or hidden behind disclosure?
- Which archetypes map cleanly to MCP tools as we expand beyond `Write`?

---

## Acceptance Criteria (Design Complete)

- Aesthetics spec covers color, motion, sound, iconography, and deterministic sigils with seeds.
- Backend fields (`archetype`, `sigilSeed`, `phase`, `tokenRate`) defined and consumed by UI.
- Accessibility and performance constraints documented with off switches.
- Desktop MVP plan scoped and mapped to concrete files; mobile concepts articulated for future.
