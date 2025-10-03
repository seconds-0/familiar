# Repository Guidelines

## Core Design Principles

### The Ive Test

Before merging any PR, verify it passes:

- **Inevitable**: Feels obvious in hindsight
- **Essential**: Nothing superfluous
- **Shows care**: Attention to detail perceptible
- **Design invisible**: User focuses on task, not UI

### Craft Checklist (Every PR)

- [ ] **Reduction**: Could anything be removed?
- [ ] **Friction**: Any unnecessary steps?
- [ ] **Alignment**: Visually aligned to 8pt grid?
- [ ] **Latency**: Feels instant? (<100ms perceived)
- [ ] **Jitter**: Text stable during streaming?
- [ ] **Dark Mode**: Tested in dark mode?
- [ ] **Accessibility**: VoiceOver tested?
- [ ] **Motion**: Uses `.familiar` spring?
- [ ] **Language**: Passes "Grandma Test"?

Reference: docs/design/aesthetic-system.md:758-801

### Language Standards

All user-facing text must pass **The Language Test**:

✅ **Good**:

- "Is that ok?"
- "Done!"
- "Hmm, something went wrong"

❌ **Bad**:

- "Approve?"
- "Operation completed successfully"
- "Error: Permission denied [Errno 13]"

## Project Structure & Module Organization

- Planning artifacts live in `docs/`; evolve `prd.md` for product scope and capture SDK learnings in `claude-agent-sdk.md` so the native build inherits accurate context.
- `backend/` hosts the FastAPI sidecar managed by `uv`; keep Python source in `src/palette_sidecar/` and document new endpoints alongside SDK changes.
- `apps/mac/FamiliarApp/` is the SwiftUI summon window prototype managed via SwiftPM; organise UI, services, and support helpers within the existing subfolders.
- `assets/claude-cli/` bundles the Claude CLI (JS, type defs, wasm); treat it as the reference toolchain when validating native integrations or scripted experiments.
- `AGENTS.md` and `CLAUDE.md` define collaboration contracts for human and automated contributors—update both whenever workflows or guardrails change.

### Key Documentation to Reference

**Design Philosophy**:

- `docs/design/aesthetic-system.md` - Core design system (READ FIRST)
- `docs/design/visual-improvements.md` - Consolidated polish tasks
- `docs/design/hidden-delights.md` - Easter eggs and discovery

**Implementation Guides**:

- `docs/implementation/steel-thread-v1.md` - V1 feature checklist
- `docs/implementation/phased-enhancements.md` - Future phases

**Technical References**:

- `docs/reference/claude-agent-sdk.md` - Complete SDK reference
- `docs/reference/swiftui-reference.md` - SwiftUI patterns

**Future Explorations**:

- `docs/future/voice-assistant.md` - Voice interface spec
- `docs/future/intelligent-zero-state.md` - Smart suggestions

**Navigation**: Start with `docs/00-README.md` for the full documentation map.

## Build, Test, and Development Commands

- Backend: `cd backend && uv run uvicorn palette_sidecar.api:app --host 127.0.0.1 --port 8765 --reload` streams Claude responses locally.
- Backend tests: `cd backend && uv run pytest tests/ -v` exercises the authentication and SSE smoke tests.
- SwiftUI app: `cd apps/mac/FamiliarApp && swift build` to resolve packages, then open the generated `.build/debug/FamiliarApp.app` or `open Package.swift` in Xcode for iterative work.
- Smoke-test the bundled CLI with `node assets/claude-cli/cli.js --help`; use this command to confirm Node dependencies or wasm binaries remain intact after updates.
- Document additional scripts (e.g., MCP installers, lint configs) in their respective subprojects and surface the commands here for quick discovery.
- Swift unit tests:
  - Direct: `swift test --package-path apps/mac/FamiliarApp`
  - Script: `./test-swift.sh`
  - Filters: `./test-swift.sh --filter PromptTextEditorTests` or `./test-swift.sh --filter testHeightCalculationPreventsjitter`
  - Verbose/coverage: pass any `swift test` flags, e.g. `./test-swift.sh --verbose` or `./test-swift.sh --enable-code-coverage`

- Packaging automation runs via `.github/workflows/steel-thread.yml`, which invokes `scripts/steel-thread-package.sh` on macOS runners and publishes the `dist/steel-thread/` payload with checksums.

### Restarting Familiar (Canonical)

- Restart everything with rebuild and logs: `./scripts/restart-familiar.sh`
  - Optional verbose sidecar logs: `./scripts/restart-familiar.sh -v`
  - What it does: kills existing processes, rebuilds the Swift app, runs Swift tests, restarts the Python sidecar (with `uvicorn --reload`), opens a live log window, and launches the app.
  - Use this to pick up code changes across the mac app and backend.

## Coding Style & Naming Conventions

- Follow `.prettierrc`: 2-space indentation, 120-character width, double quotes, and semicolons. Run `npx prettier --check .` before publishing major edits.
- Use PascalCase for React/Swift component files, camelCase for utilities, and kebab-case for directories. Co-locate domain-specific types near their implementation to keep ownership clear.
- Prefer explicit exports and typed interfaces so future desktop modules stay tree-shakeable and transparent to TypeScript tooling.

### Design Token Usage (Swift)

Always use design tokens, never hard-coded values:

```swift
// Spacing (8pt grid)
FamiliarSpacing.xs   // 8pt
FamiliarSpacing.sm   // 16pt
FamiliarSpacing.md   // 24pt
FamiliarSpacing.lg   // 32pt
FamiliarSpacing.xl   // 48pt

// Corner Radius
FamiliarRadius.control  // 8pt (buttons, fields)
FamiliarRadius.card     // 16pt (panels, sheets)

// Animation (The Familiar Spring)
.animation(.familiar, value: state)
```

### Human Language in Code

Comments and error messages should also be conversational:

```swift
// ✅ Good
// Check if the user has approved this permission yet
if !hasUserApproval {
    showApprovalSheet("Is that ok?")
}

// ❌ Bad
// Verify authorization status before proceeding with operation
if authStatus != .approved {
    displayAuthPrompt("Approve?")
}
```

## Context-Aware Development

Every interaction with Claude Agent SDK must follow **context engineering principles** to maintain performance and reliability.

### Before Adding MCP Tools

**Checklist**:

- [ ] Tool has single, clear purpose (no overlap with existing tools)
- [ ] Tool returns metadata-first (summary + identifiers, not full content)
- [ ] Tool respects context budgets (`config.py` MAX\_\* constants)
- [ ] Tool is self-contained (no hidden dependencies)

**Good Example**:

```python
# ✅ Metadata-first file listing
@mcp_tool
def list_workspace_files() -> dict:
    files = scan_directory(workspace)
    return {
        "summary": f"{len(files)} files in {workspace.name}/",
        "files": [{"path": f.path, "size": f.size, "modified": f.mtime} for f in files],
        "note": "Use read_file(path) for full content"
    }
```

**Bad Example**:

```python
# ❌ Context explosion - loads everything
@mcp_tool
def list_workspace_files() -> list:
    return [{"path": f, "content": read_file(f)} for f in scan_directory(workspace)]
```

### Context Budget Enforcement

All tool outputs must respect these limits (defined in `backend/src/palette_sidecar/config.py`):

```python
MAX_FILE_PREVIEW_SIZE = 1000      # characters
MAX_SEARCH_RESULTS = 20           # files
MAX_DIRECTORY_LISTING = 50        # entries
MAX_TOOL_OUTPUT_LENGTH = 5000     # characters
```

**Implementation Pattern**:

```python
def get_file_preview(path: str) -> str:
    content = read_file(path)
    if len(content) > MAX_FILE_PREVIEW_SIZE:
        return (
            f"{content[:MAX_FILE_PREVIEW_SIZE]}...\n\n"
            f"[{len(content):,} total chars. Use read_file(\"{path}\") for full content]"
        )
    return content
```

### System Prompt Updates

When modifying `STEEL_THREAD_SYSTEM_PROMPT` in `claude_service.py`:

1. Use structured sections (Identity, Capabilities, Constraints, Format)
2. Keep total prompt under 500 tokens
3. Reference Layer 1/2/3 abstraction for response guidance
4. Pass The Language Test (human, conversational, no corporate speak)

**Reference**: `docs/reference/claude-agent-sdk.md:Context-Engineering-Best-Practices`

### Sub-Agent Patterns

For complex workflows (e.g., "organize entire desktop"), use sub-agent composition:

```python
# Main agent coordinates
async def organize_desktop(workspace: Path):
    # Sub-agent 1: Analyze (returns summary only)
    analysis = await analyze_files(workspace)  # "47 images, 12 docs, 3 videos"

    # Sub-agent 2: Plan (returns structure only)
    plan = await create_organization_plan(analysis)  # Directory structure + rules

    # Sub-agent 3: Execute (returns outcome only)
    result = await execute_moves(plan)  # "Moved 62 files into 4 folders"

    return result  # Not full history!
```

**Why**: Each sub-agent returns summaries, preventing context accumulation.

### Validation Tools

```bash
# Measure context size for a prompt (when available)
cd backend
uv run python scripts/measure-context.py --prompt "your test prompt here"

# Expected: < 10K tokens for typical Steel Thread interaction
```

**Reference**: `docs/reference/claude-agent-sdk.md:Context-Engineering-Best-Practices` for full patterns.

## Testing Guidelines

- Backend: add pytest or `uv run ruff check`/`uv run mypy` once service endpoints solidify; keep tests under `backend/tests/`.
- SwiftUI: plan XCTest targets when the UI matures; until then document manual QA steps in PRs and record gaps in `docs/`.
- Document expected coverage goals in `docs/` and note any skipped areas inside pull request descriptions until automated suites exist.

### Accessibility Testing

**Required for Every PR**:

1. Enable VoiceOver (⌘F5) and navigate through changes
2. Enable Reduced Motion and verify animations
3. Test keyboard navigation (tab through all controls)
4. Verify color contrast (use Accessibility Inspector)
5. Check touch targets (minimum 44pt)

**Automated Tools**:

```bash
# Accessibility Inspector (Xcode)
# Color Contrast Checker
./scripts/color-contrast-checker.sh --bg "#0B0C10" --fg "#F4EDE1"
```

## Commit & Pull Request Guidelines

- Maintain the short imperative format observed in git history: `<scope>: concise action` (e.g., `docs: outline native IPC options`). Squash incidental fixups locally.
- Pull requests should describe the architectural intent, list manual/automated validation steps, and attach screenshots or transcripts for UI or CLI changes.

### PR Description Template

```markdown
## Summary

[What changed and why]

## The Ive Test

- [ ] Inevitable: Feels obvious in hindsight
- [ ] Essential: Nothing superfluous
- [ ] Shows care: Details are polished
- [ ] Design invisible: User focuses on task

## Accessibility

- [ ] VoiceOver tested
- [ ] Keyboard navigation works
- [ ] Reduced motion respected
- [ ] Color contrast verified

## Language Test

- [ ] All text sounds conversational
- [ ] "Is that ok?" style maintained
- [ ] No corporate/robotic language

## Context Engineering

- [ ] Tools return metadata-first (not full content)
- [ ] Respects MAX\_\* limits in config.py
- [ ] Tested with large files/directories (100K+ chars, 500+ files)
- [ ] Context size measured (< 10K tokens for typical flow)
- [ ] Truncation includes expansion affordances

## Screenshots/Video

[Attach for UI changes]
```

## Architecture & Security Notes

- Keep API keys, tokens, and local paths out of source-controlled docs—reference secure storage (Keychain, environment variables) instead.
- Capture significant decisions as ADR-style notes in `docs/` so future contributors understand why each native capability or dependency was introduced.

### Permission Implementation

Always use the permission template pattern:

```
I can [action] for you:
• [Detail with real numbers]
• [Another detail]

Is that ok?

[Show me how ▼]  [Not right now]  [Yes, do it]
```

See: docs/design/aesthetic-system.md:318-360

## Design Philosophy Quick Reference

### Quick Decision Guide

**"Should I add this feature?"**
→ Apply The Test from `docs/design/hidden-delights.md:493-516`

**"How should this look?"**
→ Check design tokens in `docs/design/aesthetic-system.md:522-663`

**"What should this text say?"**
→ Apply The Language Test: Would you say this to a friend?

**"How should this animate?"**
→ Use The Familiar Spring: `response: 0.3, dampingFraction: 0.7`

**"Should there be sound?"**
→ Default: No. UI sounds are OFF by default. Voice output only when enabled.

**"Which layer of detail?"**
→ Layer 1 (outcomes) by default. Layer 2/3 collapsed and optional.
