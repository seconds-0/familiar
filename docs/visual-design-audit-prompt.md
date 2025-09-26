# Familiar Visual Polish Sprint

## Mission
Own a rapid polish pass on Familiar’s macOS build so the interface feels cohesive, delightful, and ship-ready—without expanding scope beyond what already exists. As the agent, you drive the effort end-to-end and surface a tight plan for my review and feedback checkpoints.

## Aesthetic North Star
- Keywords: warm, precise, confident, whimsical-not-cute
- Visual references: Raycast’s tactile layering, Linear’s typographic discipline, Apple Reminders’ balance of focus and friendliness
- Palette direction: keep the neutral glass base, explore richer accent treatments for status states, lean on SF Symbols unless a custom glyph meaningfully improves clarity

## Agent Checklist
1. **Assemble Context**
   - Capture light & dark screenshots for empty, streaming, error, settings, and approval states
   - Record a short summon → prompt → result → settings walkthrough
   - Export the current SwiftUI view tree/layout notes and list existing color + typography tokens
   - Gather known rough edges we’ve already spotted (spacing glitches, awkward transitions, etc.)
2. **Audit & Synthesize**
   - Assess layout rhythm, typography hierarchy, color & surface treatment, control styling, and micro-interactions
   - Note quick wins vs. deeper explorations; flag any blockers that need guidance
3. **Propose Improvements**
   - Produce annotated mockups or redlines for the primary window, settings, and approval sheet (lightweight is fine)
   - Outline motion or feedback tweaks with clips/storyboards when words aren’t enough
   - Draft a prioritized polish plan tagged by effort level and expected impact

## Review Loop (Me)
- Checkpoint 1: confirm prep artifacts and aesthetic alignment before you dive into redesigns
- Checkpoint 2: react to your draft checklist + visuals, approve or redirect items
- Final sign-off: review the refined plan and note which items move into implementation

## Deliverables (Agent)
- Prioritized polish checklist split into **Quick Wins** and **Deeper Pass**, each with rationale + effort notes
- Annotated visuals for priority surfaces (Familiar window, settings, approval sheet) showing the proposed tweaks
- Optional motion notes if they clarify hover, loading, or permission flows
- Summary of implementation guidance (references to SwiftUI components, tokens to introduce, assets to create)

## Adoption Plan
1. Integrate approved Quick Wins into the upcoming UI sprint; slot Deeper Pass items into subsequent milestones
2. As changes land, drop before/after screenshots or clips back into the checklist for traceability
3. Run a lightweight visual QA sweep (contrast, spacing, edge cases) before marking the polish sprint complete
4. Document any follow-up questions or constraints in `docs/AGENTS.md` so future passes build on this work

Stay focused on sharpening what’s already here. Keep me in the loop at each checkpoint, and I’ll provide feedback so the final plan reflects a shared vision before engineering picks it up.
