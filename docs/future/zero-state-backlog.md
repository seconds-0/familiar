# Zero State Backlog

Status: Notes for later — keep scope tight for now.

## Implemented (today)
- Startup prewarm via `ZeroStateCache` (decoupled from view lifecycle)
- 30-min inactivity → archive current session and reset to zero state
- Context-aware resume suggestion (LLM) using brief preview and metadata
- Persist previous session to disk and restore on demand

## Nice-to-haves (defer)
- Resume TTL: Auto-clear persisted session after N days (e.g., 7d)
- Multiple recents: Keep last 3 sessions; show top + “More…”
- Richer context (budgeted): workspace name, project/repo from path, concise last-topic summary
- Cache TTL: Periodic refresh of zero-state suggestions (e.g., 30–60m)
- Offline fallback: Local, human-written resume labels when sidecar is down
- Privacy: Toggle to disable session persistence; “Forget this session” action
- Accessibility: Explicit VoiceOver label for resume card (“Resume last session”)
- Language: Enforce The Language Test in prompt + UI labels
- Performance: Ensure resume generation stays within context budgets and <100ms perceived on open

## Guardrails
- Metadata-first only; never send full transcripts
- Respect backend limits (`MAX_*` in config.py)
- Keep resume prompt under ~150 input tokens
- UI shows at most 4 cards; resume at top when present

## Validation ideas
- Unit: Resume label length, punctuation, friendly tone checks
- Integration: 30-min inactivity reset, persistence across restart, restore path present
- Manual: VoiceOver navigation through zero state + resume

---

See also: `docs/future/intelligent-zero-state.md` for the vision and design.
