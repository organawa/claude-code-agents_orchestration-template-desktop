---
name: build-status
description: Display current build pipeline progress and phase states
---

# Build Pipeline Status

Display the current state of the 7-phase build pipeline.

**Usage:** `/build-status`

---

## Workflow

### 1. Read Build State

Read `docs/build-state.json`.

If the file does not exist, tell the user:
> No build pipeline initialized. Fill in `docs/product-brief.md` and run `/build-phase 1` to start.

### 2. Display Pipeline Status

Show a visual pipeline with status indicators:

```
Build Pipeline — {{PROJECT_NAME}}

Phase 1: Discovery & Specification    [status]  checkpoint
Phase 2: Architecture & Design        [status]  checkpoint
Phase 3: UI/UX Design                 [status]
Phase 4: Implementation               [status]  checkpoint
Phase 5: Quality Assurance            [status]
Phase 6: DevOps & Deployment          [status]
Phase 7: Documentation & Delivery     [status]  checkpoint
```

Status indicators:
- `pending` — Not started yet
- `completed` — Done, awaiting validation (for checkpoint phases)
- `validated` — Approved by user, dependents unlocked
- `blocked` — Prerequisites not met (show which phase is blocking)

### 3. Show Available Actions

Based on current state, suggest the next command(s) the user can run:

- If a checkpoint phase is "completed" → suggest `/build-validate <N>`
- If phases are unlocked but not started → suggest `/build-phase <N>`
- If all phases are validated → announce Phase B is active

### 4. Show Phase Outputs (if any completed)

For each completed or validated phase, list the key output files:

| Phase | Key Outputs |
|-------|-------------|
| 1 | `docs/PRD.md` |
| 2 | `docs/architecture/`, `docs/database/` |
| 3 | `docs/design/` |
| 4 | Source code |
| 5 | `docs/qa/`, `docs/security/` |
| 6 | `docs/devops/`, Dockerfile, CI/CD |
| 7 | `README.md`, `docs/developer-guide.md` |

---

**This is a read-only status command. It does not modify any files.**
