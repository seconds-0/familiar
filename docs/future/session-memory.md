# Session Memory — Agent-Searchable Knowledge for Familiar

Status: Draft

This plan proposes a practical, privacy‑respecting memory system that logs meaningful session events and extracts durable facts the agent can search and use. It aims to turn “User Desire → Action” faster by recalling prior context, preferences, and artifacts without exposing terminal complexity.

---

## Goals

- Capture: log essential interactions (prompts, tool uses, approvals, results, artifacts).
- Retrieve: fast, local, structured search (keyword + semantic) for the agent and user.
- Inject: feed relevant memory back into the model at the right time and scope.
- Control: clear user consent, retention windows, redaction, and export/delete.
- Performant: small footprint, offline‑friendly; minimal latency added to requests.

---

## Memory Model

Memory is split into types so we can index and inject appropriately:

- Episodic: ordered session events (prompts, assistant summaries, tool_use, permission, tool_result, errors).
- Artifacts: pointers to created/modified files with small captured snippets/diffs.
- Facts: compact, LLM‑extracted statements from episodic logs (preferences, decisions, outcomes).
- Preferences: user‑set style/tone, workspace paths, Always Allow rules (read‑only to model).
- Pins: user‑pinned notes or results to keep beyond retention windows.

Each record carries: `id, ts, type, session_id, workspace, tool, path, content, tags[], metadata (JSON)`.

---

## Storage & Indexing (Local‑First)

- Engine: SQLite with FTS5 for keyword/BM25; JSON columns for metadata.
- File: `~/.palette-app/memory.sqlite` alongside existing `config.json`.
- Tables:
  - `records(id TEXT PRIMARY KEY, ts INTEGER, type TEXT, session_id TEXT, workspace TEXT, tool TEXT, path TEXT, content TEXT, tags TEXT, metadata TEXT)`
  - `records_fts(content, tags, path, tokenize='porter')` with content from `records` via triggers.
  - `facts(id TEXT PRIMARY KEY, ts INTEGER, session_id TEXT, workspace TEXT, content TEXT, tags TEXT, metadata TEXT)` + `facts_fts(content, tags)`.
- Retention: default 90 days for episodic; artifacts truncated to snippets; facts retained until deleted; pins never expire.
- Optional at‑rest encryption (future): SQLCipher with key in Keychain.

---

## APIs (Sidecar)

- `POST /memory/record` (internal): append event record (used by sidecar to log tool_use/result/approval/assistant summary).
- `GET /memory/search?q&k=20&type=facts|records&session_id=&workspace=&since=`: returns ranked hits with snippets, ids, and metadata.
- `POST /memory/summarize?session_id=`: run fact extraction over a session to produce durable facts.
- `DELETE /memory/record/:id` and `POST /memory/pin`: user control.
- `GET /memory/export?format=jsonl`: portability.
- SSE `memory_update`: UI can reflect newly captured facts live.

All endpoints are local; no external services.

---

## Agent Integration

Two complementary paths so the model can leverage memory safely:

1. Automatic Context Injection (zero‑shot overhead)

- Hook: `UserPromptSubmit` in sidecar.
- Flow: extract top keywords from the prompt → `FTS` search (records + facts) → select top‑K (e.g., 5 facts + 3 episodic snippets, ≤ 800 tokens total) → inject as a short System preamble: “Relevant prior context…”.
- Guardrails: scope by `workspace` and recency; never inject secrets (redaction rules below).

2. Explicit Tool (model‑pull)

- Define `MemorySearch` tool in SDK: `{query: string, top_k?: number, type?: 'facts'|'records'}` → returns small JSON of hits.
- Allowed by default (read‑only); respects same scoping and redaction.

Use both: automatic injection for speed; explicit tool when the model needs more.

---

## Fact Extraction (Haiku)

- Trigger: end of session or after significant events (≥ N tokens or tools used).
- Model: `claude-3.5-haiku-latest` with strict budget (input ≤ 2k tokens; output ≤ 10 bullets, ≤ 40 words each).
- Prompt contract: “Extract durable, user‑useful facts from the following event log. No secrets, tokens, or internal command details. Prefer preferences, decisions, task outcomes, and named artifacts. Output as JSON array of {text, tags[]}.”
- Storage: insert into `facts` and index.
- Opt‑in: users can disable automatic extraction and run it manually.

Fallback (offline): skip extraction (facts table remains empty) — retrieval still works over episodic.

---

## Redaction & Safety

- Never store: API keys, access tokens, auth headers, clipboard passwords.
- Redact patterns before persistence (common key/token regexes, 16+ hex, bearer tokens, SSH keys).
- Path scoping: only index paths under configured `workspace` unless user opts in to global.
- Sensitive tags: mark records with `sensitive:true` if heuristic matches; exclude by default from injection unless user overrides.
- Delete: per‑record purge; “forget session”; “forget workspace” bulk actions.

---

## UI Surfaces (macOS)

- Memory Search Panel: quick search with filters (facts/records, session, workspace, date).
- Inline “Add to Memory”: any transcript snippet or tool result can be pinned as a fact.
- Oath Ledger: share backend rules UI; show memory retention and sensitive exclusion toggles.
- Session Timeline: collapsible event list with jumps into artifacts.

---

## Performance Budget

- Write path: < 2 ms per record (async batched inserts every 100 ms).
- Search path: P95 < 50 ms for top‑20 FTS queries on 100k rows; stream results.
- Fact extraction: runs async; never blocks user interaction; capped to ≤ 1 s Haiku call or skipped.
- Context injection: total added tokens ≤ 800; target added latency ≤ 50 ms (local search only).

---

## Roadmap

V1 (1–2 weeks)

- SQLite + FTS5 store; episodic logging wired from sidecar events.
- `GET /memory/search` (records+facts); `POST /memory/record` internal.
- Automatic context injection (top‑K) on `UserPromptSubmit` hook.
- UI: basic Memory Search Panel; toggle to disable injection.

V2 (1–2 weeks)

- Haiku fact extraction endpoint + background job; `facts` table and search.
- MemorySearch tool for the model; safety redaction pass.
- Pins and bulk delete/export.

V3 (2 weeks)

- At‑rest encryption option; sensitive tagging UI; per‑workspace retention policies.
- Session Timeline view; SSE `memory_update` events for live facts.
- Advanced ranking: blend BM25 + recency + pin boost + “workspace affinity”.

---

## Data Shapes

Record (JSON):

```
{
  "id": "uuid",
  "ts": 1738112345123,
  "type": "tool_use|tool_result|prompt|assistant|approval|error",
  "session_id": "default",
  "workspace": "/Users/alex/…/repo",
  "tool": "Write",
  "path": "docs/README.md",
  "content": "Applied patch to README…",
  "tags": ["transmute","write"],
  "metadata": {"cost": {"total": 0.0023, "currency": "USD"}}
}
```

Fact (JSON):

```
{ "id": "uuid", "ts": 1738112345123, "session_id": "default", "workspace": "…", "content": "Prefers mystical tone, low motion.", "tags": ["preference","tone"] }
```

Search response:

```
{ "hits": [ {"id":"…","type":"fact","score":12.3,"snippet":"…"} ], "took_ms": 18 }
```

---

## Hook Points (Sidecar)

- `SessionStart`: attach session_id; start logging.
- `UserPromptSubmit`: run keyword extraction, memory search, inject context.
- `PreToolUse`/`PostToolUse`: log tool input/output metadata and diffs/snippets.
- `Stop`: summarize session if enabled.

---

## Open Questions

- Should we enable optional vector search (e.g., local MiniLM/3B embeddings) for better recall, or keep FTS‑only until scale demands more?
- How much automatic injection is helpful before it risks steering the model wrongly? (Start with ≤ 5 facts + 3 snippets.)
- Do we allow cross‑workspace recall when projects are related, or keep memory siloed by default?

---

## Acceptance Criteria (V1)

- Records persist for all core events with FTS5 searchable content.
- Top‑K memory is injected automatically on prompt submit; added latency ≤ 50 ms.
- Users can search memory from the app and disable injection at any time.
- No secrets persist; redaction and path scoping enforced.
