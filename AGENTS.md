# Repository Guidelines

## Project Structure & Module Organization
- Planning artifacts live in `docs/`; evolve `prd.md` for product scope and capture SDK learnings in `claude-code-sdk.md` so the native build inherits accurate context.
- `backend/` hosts the FastAPI sidecar managed by `uv`; keep Python source in `src/palette_sidecar/` and document new endpoints alongside SDK changes.
- `apps/mac/FamiliarApp/` is the SwiftUI summon window prototype managed via SwiftPM; organise UI, services, and support helpers within the existing subfolders.
- `assets/claude-cli/` bundles the Claude CLI (JS, type defs, wasm); treat it as the reference toolchain when validating native integrations or scripted experiments.
- `AGENTS.md` and `CLAUDE.md` define collaboration contracts for human and automated contributors—update both whenever workflows or guardrails change.

## Build, Test, and Development Commands
- Backend: `cd backend && uv run uvicorn palette_sidecar.api:app --host 127.0.0.1 --port 8765 --reload` streams Claude responses locally.
- SwiftUI app: `cd apps/mac/FamiliarApp && swift build` to resolve packages, then open the generated `.build/debug/FamiliarApp.app` or `open Package.swift` in Xcode for iterative work.
- Smoke-test the bundled CLI with `node assets/claude-cli/cli.js --help`; use this command to confirm Node dependencies or wasm binaries remain intact after updates.
- Document additional scripts (e.g., MCP installers, lint configs) in their respective subprojects and surface the commands here for quick discovery.
- Swift unit tests:
  - Direct: `swift test --package-path apps/mac/FamiliarApp`
  - Script: `./test-swift.sh`
  - Filters: `./test-swift.sh --filter PromptTextEditorTests` or `./test-swift.sh --filter testHeightCalculationPreventsjitter`
  - Verbose/coverage: pass any `swift test` flags, e.g. `./test-swift.sh --verbose` or `./test-swift.sh --enable-code-coverage`

## Coding Style & Naming Conventions
- Follow `.prettierrc`: 2-space indentation, 120-character width, double quotes, and semicolons. Run `npx prettier --check .` before publishing major edits.
- Use PascalCase for React/Swift component files, camelCase for utilities, and kebab-case for directories. Co-locate domain-specific types near their implementation to keep ownership clear.
- Prefer explicit exports and typed interfaces so future desktop modules stay tree-shakeable and transparent to TypeScript tooling.

## Testing Guidelines
- Backend: add pytest or `uv run ruff check`/`uv run mypy` once service endpoints solidify; keep tests under `backend/tests/`.
- SwiftUI: plan XCTest targets when the UI matures; until then document manual QA steps in PRs and record gaps in `docs/`.
- Document expected coverage goals in `docs/` and note any skipped areas inside pull request descriptions until automated suites exist.

## Commit & Pull Request Guidelines
- Maintain the short imperative format observed in git history: `<scope>: concise action` (e.g., `docs: outline native IPC options`). Squash incidental fixups locally.
- Pull requests should describe the architectural intent, list manual/automated validation steps, and attach screenshots or transcripts for UI or CLI changes.

## Architecture & Security Notes
- Keep API keys, tokens, and local paths out of source-controlled docs—reference secure storage (Keychain, environment variables) instead.
- Capture significant decisions as ADR-style notes in `docs/` so future contributors understand why each native capability or dependency was introduced.
