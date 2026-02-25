# GitHub Configuration Reference

**Purpose:** Central reference for all GitHub Project IDs, status values, priorities, and naming conventions.

**Use this file when:** Setting up issues, updating project statuses, or naming new issues.

<!-- SETUP REQUIRED: Run setup.sh or manually replace all REPLACE_ME values -->
<!-- To fetch IDs: gh project field-list {{GITHUB_PROJECT_NUMBER}} --owner {{GITHUB_OWNER}} -->

---

## Project Configuration

**Project ID:** `{{GITHUB_PROJECT_ID}}`
**Project URL:** {{GITHUB_PROJECT_URL}}
**Owner:** {{GITHUB_OWNER}}
**Repository:** {{GITHUB_REPO}}

---

## Field IDs

| Field Name | Field ID | Purpose |
|------------|----------|---------|
| Status | `{{STATUS_FIELD_ID}}` | Issue workflow status |
| Priority | `{{PRIORITY_FIELD_ID}}` | P1-P4 priority levels |
| Story Points | `{{SP_FIELD_ID}}` | Issue size estimate |
| Sprint | `{{SPRINT_FIELD_ID}}` | Sprint assignment |
| Type | `{{TYPE_FIELD_ID}}` | Epic/Story/Task classification |

---

## Status IDs

| Status Name | Status ID | When to Use |
|-------------|-----------|-------------|
| **Todo** | `{{STATUS_TODO}}` | Issue created but not started |
| **In Progress** | `{{STATUS_IN_PROGRESS}}` | Development ongoing (general) |
| **Dev Started** | `{{STATUS_DEV_STARTED}}` | Set this when starting work on ANY issue |
| **Automated Tests** | `{{STATUS_AUTO_TESTS}}` | Running automated test suites (backend + frontend + e2e) |
| **Ready for testing** | `{{STATUS_READY_TEST}}` | Automated tests passed, awaiting user/dev testing |
| **Being tested** | `{{STATUS_BEING_TESTED}}` | User actively testing on develop branch |
| **Ready for Prod** | `{{STATUS_READY_PROD}}` | User approved, ready to deploy |
| **Done** | `{{STATUS_DONE}}` | Deployed to production OR closed without deploy |

### Status Workflow

```
Todo → Dev Started → Automated Tests → Ready for testing → Being tested → Ready for Prod → Done
                        ↑________________|
                        (if tests fail)
```

---

## Priority IDs

**Field ID:** `{{PRIORITY_FIELD_ID}}`

| Priority | Priority ID | Definition |
|----------|-------------|------------|
| **P1 - Critical** | `{{PRIORITY_P1}}` | Blocking issues, security vulnerabilities, data loss, production down |
| **P2 - High** | `{{PRIORITY_P2}}` | Important features, significant bugs, affects many users |
| **P3 - Medium** | `{{PRIORITY_P3}}` | Enhancements, nice-to-have features, minor bugs |
| **P4 - Low** | `{{PRIORITY_P4}}` | Polish, tech debt, future improvements |

### Priority Guidelines

- **P1:** Work on immediately, interrupt other work if necessary
- **P2:** Include in current or next sprint
- **P3:** Add to backlog, plan for future sprint
- **P4:** Backlog, work when capacity allows

---

## Sprint Field Values

**Field ID:** `{{SPRINT_FIELD_ID}}`

| Sprint Name | Sprint ID | Dates |
|-------------|-----------|-------|
| **Backlog** | `{{SPRINT_BACKLOG}}` | Unscheduled work |
| **Sprint 1** | `{{SPRINT_1}}` | First implementation sprint |
| **Sprint 2** | `{{SPRINT_2}}` | Second sprint |
| **Sprint 3** | `{{SPRINT_3}}` | Third sprint |

**Note:** All issues are created in Backlog. When `/start-issue` is first called, planned issues move to Sprint 1. Add new sprint values as needed.

---

## Issue Naming Convention

### Format

```
[TYPE]-[CATEGORY] Description
```

**Components:**
1. **TYPE:** E-/S-/T- (Epic/Story/Task)
2. **CATEGORY:** Feature type in brackets
3. **Description:** Brief, clear summary

### Type Prefix

| Prefix | Type | Story Points | Definition |
|--------|------|--------------|------------|
| `E-` | Epic | 13+ SP | Large feature spanning multiple sprints |
| `S-` | Story | 3-8 SP | User-facing feature, deliverable in 1 sprint |
| `T-` | Task | 1-3 SP | Technical work, subtask, single deliverable |

### Category Prefix

| Category | Definition | Examples |
|----------|------------|----------|
| `[FEAT]` | New feature | New page, new tool, new API endpoint |
| `[ENH]` | Improvement to existing feature | Better UX, performance boost |
| `[BUG]` | Bug fix | Broken functionality, incorrect behavior |
| `[UI]` | Visual / layout | Styling, colors, spacing, alignment |
| `[UX]` | Workflow / usability | User experience, navigation |
| `[SEC]` | Security | Authentication, encryption, vulnerabilities |
| `[PERF]` | Performance | Speed optimization, caching |
| `[REFAC]` | Refactoring / code cleanup | Code quality, tech debt |
| `[INFRA]` | CI/CD, deployment, infrastructure | Docker, GitHub Actions |
| `[DOCS]` | Documentation | README, guides, API docs |
| `[GOV]` | Governance | Process, workflow, organizational review |
| `[CHORE]` | Dependencies, config, housekeeping | npm update, config changes |

### Examples

- `T-[BUG] Fix dropdown menu not closing on mobile`
- `S-[FEAT] Add multi-account switching UI`
- `E-[FEAT] Payment System Integration`

---

## Workflow Tier Mapping

`/start-issue` auto-detects the workflow tier from the `[CATEGORY]` prefix in the issue title.

| Tier | Categories | Lifecycle |
|------|-----------|-----------|
| **Dev** | `FEAT`, `BUG`, `ENH`, `REFAC`, `PERF`, `SEC`, `UI`, `UX` | Full: branch → test → merge → deploy |
| **Lightweight** | `INFRA`, `DOCS`, `GOV`, `CHORE` | Simplified: status + doc + comment → work → close |

**Default:** If category is not recognized, default to Dev tier.

---

## GitHub CLI Command Templates

### Create Issue

```bash
gh issue create \
  --title "[TYPE]-[CATEGORY] Description" \
  --body "Detailed description here"
```

### Add Issue to Project

```bash
gh project item-add {{GITHUB_PROJECT_NUMBER}} \
  --owner {{GITHUB_OWNER}} \
  --url <issue-url>
```

### Get Project Item ID

```bash
gh api graphql -f query='
query {
  repository(owner: "{{GITHUB_OWNER}}", name: "{{GITHUB_REPO}}") {
    issue(number: <NUMBER>) {
      projectItems(first: 5) {
        nodes { id }
      }
    }
  }
}'
```

### Update Status

```bash
gh project item-edit \
  --id "<ITEM_ID>" \
  --project-id "{{GITHUB_PROJECT_ID}}" \
  --field-id "{{STATUS_FIELD_ID}}" \
  --single-select-option-id "<STATUS_ID>"
```

### Set Priority

```bash
gh project item-edit \
  --id "<ITEM_ID>" \
  --project-id "{{GITHUB_PROJECT_ID}}" \
  --field-id "{{PRIORITY_FIELD_ID}}" \
  --single-select-option-id "<PRIORITY_ID>"
```

### Set Story Points

```bash
gh project item-edit \
  --id "<ITEM_ID>" \
  --project-id "{{GITHUB_PROJECT_ID}}" \
  --field-id "{{SP_FIELD_ID}}" \
  --number <STORY_POINTS>
```

### Assign to Sprint

```bash
gh project item-edit \
  --id "<ITEM_ID>" \
  --project-id "{{GITHUB_PROJECT_ID}}" \
  --field-id "{{SPRINT_FIELD_ID}}" \
  --single-select-option-id "<SPRINT_ID>"
```

### Set Type

```bash
gh project item-edit \
  --id "<ITEM_ID>" \
  --project-id "{{GITHUB_PROJECT_ID}}" \
  --field-id "{{TYPE_FIELD_ID}}" \
  --single-select-option-id "<TYPE_ID>"
```

### Add Comment / Close Issue

```bash
gh issue comment <number> --body "Comment text"
gh issue close <number> --comment "Closing comment"
```

---

## Type Field Option IDs

- Epic = `{{TYPE_EPIC}}`
- Story = `{{TYPE_STORY}}`
- Task = `{{TYPE_TASK}}`

---

## Labels

| Label | Color | When to Use |
|-------|-------|-------------|
| `epic` | Purple | 13+ SP work items |
| `story` | Green | 3-8 SP user-facing features |
| `task` | Blue | 1-3 SP technical work |
| `bug` | Red | Bugs and fixes |

---

## Related Documentation

- [WORK_ITEMS.md](WORK_ITEMS.md) — Work item hierarchy details

---

**Last Updated:** {{DATE}}
