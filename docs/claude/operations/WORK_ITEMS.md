# Epic / Story / Task Framework

## Overview

This project follows a standard Agile work item hierarchy to organize, estimate, and track all development work. Every issue in GitHub is classified as an **Epic**, **Story**, or **Task**.

```
Epic (13+ SP)
├── Story (3-8 SP)
│   ├── Task (1-3 SP)
│   └── Task (1-3 SP)
├── Story (3-8 SP)
│   └── Task (1-3 SP)
└── Task (1-3 SP)          ← small items can live directly under an epic
```

---

## Work Item Types

### Epic
> A large body of work representing a theme or major feature.

| Attribute | Value |
|-----------|-------|
| **SP Range** | 13+ (sum of children) |
| **Spans** | Multiple sprints |
| **Children** | Stories and/or Tasks |
| **Label** | `epic` |
| **Title format** | `E-[CATEGORY] Description` |
| **Threshold** | If <13 SP → keep as Story |

**Key sections:** Overview, Success Criteria, Child Issues, Total SP, Target Sprint(s)

### Story
> A user-facing deliverable that provides value.

| Attribute | Value |
|-----------|-------|
| **SP Range** | 3-8 |
| **Spans** | Fits within one sprint |
| **Children** | Tasks (recommended for 5+ SP, required for 8 SP) |
| **Label** | `story` |
| **Title format** | `S-[CATEGORY] Description` |
| **Threshold** | If >8 SP → promote to Epic. If <3 SP → demote to Task |

**Key sections:** User Story ("As a [user], I want..."), Acceptance Criteria, Tasks, SP

### Task
> The smallest unit of work. A concrete, technical action item.

| Attribute | Value |
|-----------|-------|
| **SP Range** | 1-3 |
| **Spans** | Completable in days |
| **Children** | None (leaf node) |
| **Label** | `task` |
| **Title format** | `T-[CATEGORY] Description` |
| **Threshold** | If >3 SP → promote to Story |

**Key sections:** Description, Definition of Done, Parent link, SP

### Bug
> A defect in existing functionality. Treated as a Task (1-3 SP).

- **Label:** `bug`, `task`
- **Title format:** `T-[BUG] Description`

---

## Story Points Scale

Story points estimate the **user's time investment** (review, testing, decisions).

| SP | User Time | Typical Work |
|----|-----------|-------------|
| 1 | 15-20 min | Review simple fix, quick test |
| 2 | 30-45 min | Review small feature, test, approve |
| 3 | 1 hour | Review refactoring, thorough testing |
| 5 | 2 hours | Review major changes, integration testing |
| 8 | 3-4 hours | Review large feature, extensive testing |
| 13 | 6+ hours | **TOO BIG** — must break down |

**Classification:** 1-3 SP = Task, 3-8 SP = Story, 13+ SP = Epic

---

## Definition of Done (DoD)

### Global DoD (applies to ALL items)

- [ ] Code committed and pushed to feature branch
- [ ] Automated tests pass
- [ ] No regressions introduced
- [ ] Merged to `develop` after tests pass
- [ ] Test protocol proposed to user

### Item-Level DoD

| Type | DoD Name | Focus |
|------|----------|-------|
| **Task** | Definition of Done | Technical |
| **Story** | Acceptance Criteria | User-facing |
| **Epic** | Success Criteria | Business outcome |

---

## GitHub Implementation

### Type Field Option IDs

- Epic = `{{TYPE_EPIC}}`
- Story = `{{TYPE_STORY}}`
- Task = `{{TYPE_TASK}}`

### Sub-Issues (Parent-Child Relationships)

```bash
# Link sub-issue
node_id=$(gh api repos/{{GITHUB_OWNER}}/{{GITHUB_REPO}}/issues/<CHILD> --jq '.id')
gh api repos/{{GITHUB_OWNER}}/{{GITHUB_REPO}}/issues/<PARENT>/sub_issues --method POST -F sub_issue_id="$node_id"
```

### Promotion / Demotion Rules

```
Task (1-3 SP) ←→ Story (3-8 SP) ←→ Epic (13+ SP)
```

---

## Related Documentation

- [GITHUB_CONFIG.md](GITHUB_CONFIG.md) — Field IDs, status values, CLI templates

---

**Last Updated:** {{DATE}}
