# Narrative Magic Layer — Translating Tool Calls into Thinking Prose

Status: Draft

The goal is to turn User Desire → Action for non‑technical users by abstracting Claude Code’s tool orchestration behind a concise, trustworthy, and enchanting “thinking prose” narration. The system explains what’s happening without exposing terminals, flags, or raw tool names—while remaining accurate, fast, and controllable.

---

## Objectives

- Reduce cognitive load: convey intent, progress, and outcomes in human terms.
- Preserve trust: narration must map 1:1 to real system states and approvals.
- Keep speed: zero extra latency for core operations; narration is incremental.
- Stay on brand: solemn, ritual tone (instruments, seals), never cutesy.

---

## Principles

- Truthful Illusion: poetic framing atop precise state; never fabricate capability.
- Deterministic & Minimal: templates first, small variations; no rambling.
- Consent Forward: approvals become formal oaths; risks stated plainly.
- Graceful Silence: when there’s nothing meaningful, say less.

---

## Tone System & Personalization

Default tone: calm, a little exciting, and mystical — ritual vocabulary with concise, confident phrasing.

Personalization (future iterations):

- Tone Packs (select one):
  - Direct: plain, matter‑of‑fact (“Scanning… Done.”)
  - Mystical: current default (“Gathering implements… Sealing result.”)
  - Formal: crisp professional (“Preparing prerequisites… Applying changes.”)
  - Casual: friendly but not cutesy (“On it—setting things up.”)

- Sliders (0–3):
  - Mysticism Intensity: reduces/raises ritual metaphors.
  - Verbosity: terse ↔ explanatory (caps at one sentence).
  - Excitement: calm ↔ energetic (affects adverbs and exclamations, limited).

- Inline Attunement:
  - One‑tap chips: “More direct” / “More mystical” adapt the next lines only.
  - Remember my preference: persists to settings after two consecutive selections.

Implementation notes:

- Template Dictionaries: every narrative template exists across tone packs and intensity levels; selection is deterministic from (phase, tone, intensity, hash).
- Settings:
  - UI toggles under “Familiar Style”: `tonePack`, `mysticismIntensity`, `verbosity`, `excitement`.
  - Sidecar need not be aware; changes are client‑only for V1–V2.
- Safety: regardless of tone, boundary and risk language remains explicit and unchanged.

Acceptance (tone):

- V1: default mystical tone only; copy follows style guide.
- V2: add Style panel with tone pack and intensity; inline attunement chips; persist preferences.

## User Model

- Ask (Desire): freeform input; system derives a short intent synopsis.
- Witness (Narration): see a small sequence of statements that mirror phases.
- Consent (Oath): approve/deny with a clear why and what.
- Receive (Result): concise outcome + affordances to continue.

---

## Architecture Overview

A thin “Narrative Magic Layer” sits between sidecar events and the UI transcript and produces short, human narration using a small model (Haiku) at key transitions. Flavor/liveness remains template‑based; core narration is LLM‑generated.

- Event In: sidecar SSE (`assistant_text`, `tool_use`, `permission_request`, `tool_result`, `result`, `error`).
- Event Ledger: rolling buffer (e.g., last 30 events with fields: type, path, archetype, phase, duration, outcome).
- Summarizer (Haiku): on specific triggers, generate 1–2 sentences grounded strictly in the ledger.
- Flavor Layer: tiny deterministic template lines for loading/idle fun (no promises, no details).
- Event Out: UI receives both the original stream and `narrative` events.

Default model: `claude-3.5-haiku-latest`. If unavailable, fall back to terse templates (see Fallbacks).

---

## Phases & Mapping

Phases cover most tasks (extendable):

1. Prepare — “gather tools”, “survey context”
2. Delegate — “summon a minion/subagent”
3. Execute — “perform the rite / transmute”
4. Verify — “check the result / seal it”
5. Deliver — “present the artifact / next steps”

Event mapping:

- `assistant_text(thinking)` → Prepare
- `tool_use(name=Search/HTTP/etc.)` → Prepare/Delegate (Scry)
- `tool_use(name=Write/Shell/etc.)` → Execute (Transmute/Invoke)
- `permission_request` → Boundary before Execute; show Oath
- `tool_result` → Verify (success/error), sometimes Deliver
- `result` → Deliver (usage/cost/summary)
- `error` → Abort → concise failure line + remedy

Sidecar should also emit `phase` hints where possible.

---

## LLM Narration (V1)

Core narration is produced by Haiku at phase boundaries; small flavor lines remain template‑based.

Trigger points (typical):

- On user submit (Prepare)
- On first `tool_use` (Delegate or Execute)
- On `permission_request` (Oath)
- On first `tool_result` (Verify)
- On `result` (Deliver)
- On `error` (Fail)

Prompt skeleton (system + user):

- System: “You are a concise narrator for an automation assistant. Summarize current progress in 1–2 sentences. Be accurate, avoid tool names/flags, and reflect approvals and boundaries plainly. Tone is {tonePack}/{intensity}. If action may violate terms/law, state the boundary and propose compliant alternatives. Never claim completion early.”
- User content: compact JSON of the Event Ledger slice + request synopsis + current phase + any boundary flags. Example:

```
{
  "intent": "Download the provided video to Media/",
  "phase": "delegate",
  "events": [
    {"t":"assistant_text","phase":"prepare","dt":220},
    {"t":"tool_use","arch":"scry","name":"http_fetch","dt":0},
    {"t":"permission_request","path":"~/Media","dt":0}
  ],
  "boundaries": ["site_terms_uncertain"],
  "workspace":"~/Media"
}
```

Output contract:

- 1–2 sentences, ≤ 35 words total.
- No tool names, commands, or file contents.
- If `boundaries` non‑empty, include a single‑clause boundary note and 1 alternative.
- Include no emojis; no exclamation points except in “success” if user tone prefers.

---

## Tone & Safety Rules

- No tool names, flags, or stack traces in prose; those remain in expandable details.
- If user intent risks violating terms or law (e.g., third‑party video downloading), the narration must:
  - state the boundary plainly (“This may violate the site’s terms.”),
  - offer compliant alternatives (open in app/site, save link, use official APIs, or download only owned/licensed media),
  - request explicit confirmation before proceeding if compliant path exists.
- Always disclose when asking for elevated capability: “I need permission to modify files here.”

Fallbacks:

- If Haiku fails/times out (>1s budget) → emit no narration for that trigger, or emit a terse template line.
- If user disables Prose Mode → templates only, flavor minimal.

---

## UX Surfaces (Desktop)

- Narrative Strip: a compact list above the transcript showing 3–6 lines per task (one per phase). Collapsible.
- Oath Sheet: keep current diff/preview; add the concise explanatory line at top.
- Sidebar (Agentarium): instrument tiles label with phase (“Scouting”, “Transmuting”, “Verifying”).
- While‑You‑Wait: one gentle inline prompt with context‑aware suggestion (optional).
- Details Toggle: “Show technical details” expands to real tool names/paths/commands as needed.

---

## Aspirational Mobile Paradigm

- Live Activity / Dynamic Island: shows current phase (“Summoning helper…”, “Transmuting…”, “Sealing…”) with progress pulse.
- Notification Actions: approval as a biometric‑confirmed “seal”.
- Compact Narration: 1–2 lines per phase; tap to open a task card with details.
- While‑You‑Wait: a single tappable suggestion (“Queue another request”).

---

## Implementation Plan

V1 Haiku‑Driven Narration (preferred): 1–2 weeks

- Backend (sidecar)
  - Event Ledger: maintain last N events with minimal fields; expose to summarizer.
  - Summarizer: add a small, budgeted Haiku call on triggers; 200 input tokens cap, 50 output max, 1s timeout, no streaming.
  - Emit `narrative` SSE events containing text + phase + tone metadata.
  - Emit `phase` hints, `archetype`, `sigilSeed`; classify long‑running steps (>N seconds) to trigger Waiting flavor.
  - Fail‑safe: if timeout/error, skip narration or emit terse template.

- UI (SwiftUI)
  - `NarrativeEngine` consumes `narrative` events; de‑dupe by phase; animate into a `NarrativeStripView`.
  - `ApprovalSheet` prepends Oath line (from template) plus optional Haiku line if available.
  - Settings: Prose Mode toggle; Tone Pack selection; Details toggle.

V2 Hybrid Enhancements: +1–2 weeks

- Streamed micro‑updates (throttled) during long Execute; one line every ≥4s.
- “While you wait” suggestion powered by a tiny prompt using the same ledger.

V3 Delegation & Suggestions: +2 weeks

- Detect subagent/minion spawns and narrate delegation explicitly; user can open details.
- Retry/resume narration flows and failure remedies.

---

## Data & Types

Sidecar SSE additions (examples):

```json
{ "type": "tool_use", "archetype": "scry", "phase": "prepare", "sigilSeed": "a1b2c3d4" }
{ "type": "permission_request", "phase": "execute", "path": "notes/todo.md", "sigilSeed": "…" }
{ "type": "tool_result", "phase": "verify", "isError": false, "path": "…" }
{ "type": "result", "phase": "deliver", "usage": {…} }
{ "type": "narrative", "phase": "execute", "text": "Fetching and preparing the file now.", "tone":"mystical/1" }
```

UI models:

- `NarrativePhase`: prepare | delegate | execute | verify | deliver | wait | fail
- `NarrativeEvent`: { phase, text, time, ref (event id) }
- `NarrativeEngine.map(event) -> [NarrativeEvent]`

---

## Copy Style Guide

- One sentence, present tense, < 12 words.
- Avoid metaphors that mislead about risk or control.
- Use concrete nouns (tools → implements, agents → helpers/minions) sparingly.
- Prefer: “I can do that.” over “I will attempt to…”

---

## Examples

1. “Download a specific video” (rights‑respecting path)

- Prepare: “I can do that. Surveying the source.”
- Delegate: “Summoning a helper to fetch the media.”
- Oath (if needed): “To save it, I need permission to write in ‘Media/’. You’ll see a preview.”
- Execute: “Fetching and preparing the file now.”
- Verify: “Checking the file is playable.”
- Deliver: “All set. The video is saved in Media/.”
- Boundary note (if applicable): “This may violate the site’s terms. I can use the official share/save instead.”

2. “Rename all PNGs to kebab‑case”

- Prepare: “I can do that. Scanning your images.”
- Oath: “I’ll update 24 filenames in ‘Screenshots/’. Approve to proceed.”
- Execute: “Transmuting names now.”
- Verify: “Confirming there are no clashes.”
- Deliver: “Done. All 24 images are renamed.”

---

## Risks & Mitigations

- Over‑narration → cap lines and suppress duplicates.
- Drift from truth → templates bound only to verified states; details remain available.
- Latency from micro‑summaries → keep optional and off by default.
- Legal/ToS issues → boundary templates + compliant alternatives.

---

## Acceptance Criteria (V1)

- Users see ≤ 6 narrative lines per task reflecting true phase progression.
- Approvals include a single plain‑English Oath line plus diff/preview.
- Settings expose Prose Mode and Details toggle.
- No additional latency to core operations; narration updates stream independently.

---

## File‑Level Changes (Checklist)

- Sidecar
  - `backend/src/palette_sidecar/claude_service.py`: emit `phase`, `archetype`, `sigilSeed` in relevant events; expose long‑running hints.
- macOS App
  - `Support/NarrativeEngine.swift`: new mapper from SSE → narrative lines.
  - `UI/NarrativeStripView.swift`: compact list with phase icons.
  - `UI/ApprovalSheet.swift`: add Oath line.
  - `Support/AppState.swift` + Settings: Prose Mode toggle, Details toggle.

---

## Open Questions

- Where should micro‑summaries run (sidecar vs. client) if we enable them?
- How much variety is desirable before it feels chatty?
- Do we show a single consolidated final narrative line in the transcript when the user dismisses the window?
- Should we enable an advanced “Local summarizer” mode on Apple Silicon (e.g., 3B 4‑bit quantized) for offline use, acknowledging battery/size costs?
