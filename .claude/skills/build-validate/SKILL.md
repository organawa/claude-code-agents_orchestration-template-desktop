---
name: build-validate
description: Validate and approve a build pipeline phase checkpoint
---

# Build Phase Validation

Human checkpoint — validate and approve a completed build phase. This unlocks dependent phases.

**Usage:** `/build-validate <phase-number>`

**Arguments:**
- `$ARGUMENTS` - Phase number (1, 2, 4, or 7)

---

## Workflow

### 1. Read Build State

Read `docs/build-state.json` and verify:
- The requested phase exists and has `"checkpoint": true`
- The phase status is `"completed"` (not already validated, not still pending)

If the phase is not completed yet, tell the user to run `/build-phase $ARGUMENTS` first.

### 2. Display Phase Summary

#### Phase 1 — PRD Validation
- Read `docs/PRD.md`
- Display: executive summary, persona count, functional requirement count, user story count, open questions list
- Ask: "Does this PRD accurately capture your product requirements? Any changes needed?"

#### Phase 2 — Architecture Validation
- Read `docs/architecture/` and `docs/database/`
- Display: ADR summaries, container diagram overview, API endpoint count, database table count, key technology choices
- Ask: "Does this architecture meet your technical requirements? Any concerns?"

#### Phase 4 — Implementation Validation
- List files created (backend routes, frontend pages, shared types)
- Display instructions to smoke-test:
  - How to start the dev servers
  - Key URLs to test
  - Expected behavior for core features
- Ask: "Have you tested the application? Is the core functionality working?"

#### Phase 7 — Final Delivery
- Display documentation completeness checklist:
  - [ ] README.md complete
  - [ ] Developer guide complete
  - [ ] Test suite passing
  - [ ] Security audit complete
  - [ ] Docker configuration present
  - [ ] CI/CD pipeline configured
- Ask: "Do you accept this delivery? The project will transition to Issue Lifecycle mode for ongoing development."

### 3. Wait for User Confirmation

**STOP and wait.** Do not proceed until the user explicitly confirms validation.

If the user requests changes:
- Note the feedback
- Suggest re-running the phase with adjustments, or making targeted fixes
- Do NOT mark the phase as validated

### 4. Record Validation

Once the user confirms:

Update `docs/build-state.json`:
- Set the phase status to `"validated"`
- Add `"validated_at": "<current date>"`

### 5. Announce Next Steps

| Validated Phase | Unlocked |
|-----------------|----------|
| 1 | Phase 2 |
| 2 | Phases 3 and 4 |
| 4 | Phases 5 and 6 |
| 7 | Phase B — Issue Lifecycle mode |

Display which phases are now available and suggest the next `/build-phase` command.

After Phase 7 validation:
> **Build pipeline complete.** The project is now in Phase B — Issue Lifecycle mode.
> Use `/create-issue` to create maintenance and evolution issues.
> Use `/start-issue <number>` to begin working on them.

---

**This is a human checkpoint. Do not auto-validate. Always wait for explicit user confirmation.**
