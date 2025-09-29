# EXA-code Project Bootstrap Idea

> Always begin new Familiar projects with fresh, authoritative context gathered via EXA-code.

## Why This Matters

- **Fresh context**: Pulls up-to-date docs, release notes, and community snippets before any code lands.
- **Faster ramp-up**: Developers step into new projects with a curated research digest instead of cold starts.
- **Lower risk**: Claude works from grounded sources, reducing hallucinations and outdated patterns.

## Desired Workflow

1. **Kickoff trigger**
   - CLI command or UI action signals a new project/feature start.
   - Agent captures quick metadata (tech stack, target platforms, key concerns).

2. **EXA-code queries**
   - Execute `use exa-code:` searches per topic with:
     - Allowlist domains (vendor docs, trusted blogs, GitHub).
     - Recency window (e.g., last 12 months).
     - Snippets + highlight extraction.

3. **Research brief assembly**
   - Group results into sections: Official guidance, Reference implementations, Common pitfalls.
   - Save markdown digest in `docs/research/<project>.md` plus raw JSON for agents.

4. **Claude handoff**
   - Prepend the digest to the initial plan prompt.
   - Surface quick-open links in the UI so humans can scan sources.

## Implementation Sketch

- **Script**: `scripts/research/bootstrap_project.py`
  - Inputs: project name, tags, optional extra keywords.
  - Calls EXA-code API, respecting configurable rate limits and budgets.
  - Outputs: markdown summary + machine-readable cache.

- **Configuration**
  - Store `EXA_API_KEY` securely (Keychain or `.env.local`).
  - Maintain per-project allow/block lists.
  - Tunable knobs: result count, freshness window, snippet length.

- **Agent updates**
  - Document the bootstrap requirement in `docs/AGENTS.md`.
  - Provide a prompt snippet template referencing the generated digest.

## Open Questions

- How do we cache results to avoid burning credits on repeated kickoffs? (Likely hash queries + TTL.)
- Should the CLI display estimated EXA spend per run?
- Where do stored assets live (repo vs. S3) and how long do we keep them?

## Next Steps

1. Prototype a single EXA-code query and capture a sample digest.
2. Define kickoff metadata schema (required tags, optional context fields).
3. Decide storage + retention policy for research artifacts.
4. Add opt-in toggle in settings once the flow feels stable.

This idea keeps the current build clean while laying groundwork for EXA-powered onboarding when we’re ready to invest.
