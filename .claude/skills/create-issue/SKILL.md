---
name: create-issue
description: Create and configure a new GitHub issue with project board setup
---

# Create Issue Workflow

Create a new GitHub issue, configure it on the project board, and optionally create child issues.

**Usage:** `/create-issue <description or existing issue number>`

**Arguments:**

- `$ARGUMENTS` - A description of the work needed, OR an existing issue number to configure

**References:**

- GitHub field IDs, gh commands, naming conventions: `docs/claude/operations/GITHUB_CONFIG.md`
- Work item types: `docs/claude/operations/WORK_ITEMS.md`

---

## Workflow

### 1. Determine Input Type

If `$ARGUMENTS` is a number, fetch the existing issue:

```bash
gh issue view $ARGUMENTS --json number,title,body,labels
```

If `$ARGUMENTS` is a description, proceed to estimation (step 2).

### 2. Estimate Story Points

Analyze the request and estimate story points using the Fibonacci scale:

| SP  | User Time | Typical Work                       |
| --- | --------- | ---------------------------------- |
| 1   | 15-20 min | Simple fix, quick test             |
| 2   | 30-45 min | Small feature, review + test       |
| 3   | 1 hour    | Refactoring, thorough testing      |
| 5   | 2 hours   | Major changes, integration testing |
| 8   | 3-4 hours | Large feature, extensive testing   |
| 13  | 6+ hours  | **TOO BIG** — must break down      |

**Present the estimate to the user for confirmation before creating.**

### 3. Classify Issue Type

Based on confirmed story points:

| SP Range | Type  | Prefix | Label   |
| -------- | ----- | ------ | ------- |
| 1-3      | Task  | `T-`   | `task`  |
| 3-8      | Story | `S-`   | `story` |
| 13+      | Epic  | `E-`   | `epic`  |

**Note:** 3 SP is the boundary — use Task if technical, Story if user-facing.

### 4. Pick Category Prefix

Select the most appropriate category:

| Category  | When to Use                        |
| --------- | ---------------------------------- |
| `[FEAT]`  | New feature                        |
| `[ENH]`   | Improvement to existing feature    |
| `[BUG]`   | Bug fix                            |
| `[UI]`    | Visual / layout changes            |
| `[UX]`    | Workflow / usability               |
| `[SEC]`   | Security                           |
| `[PERF]`  | Performance optimization           |
| `[REFAC]` | Code cleanup / tech debt           |
| `[INFRA]` | CI/CD, deployment, infrastructure  |
| `[DOCS]`  | Documentation                      |
| `[GOV]`   | Governance, process, workflow      |
| `[CHORE]` | Dependencies, config, housekeeping |

### 5. Generate Title

Format: `[TYPE]-[CATEGORY] Clear description`

Examples:

- `T-[BUG] Fix dropdown menu not closing on mobile`
- `S-[FEAT] Add multi-account switching UI`
- `E-[FEAT] Payment System Integration`

### 6. Write Issue Body

**For Tasks:**

```markdown
## Description

<what to do and why>

## Definition of Done

- [ ] <specific technical criterion 1>
- [ ] <specific technical criterion 2>
- [ ] Code committed and tests passing
- [ ] No regressions introduced
```

**For Stories:**

```markdown
## User Story

As a [user], I want [feature], so that [benefit].

## Acceptance Criteria

- [ ] <user-facing criterion 1>
- [ ] <user-facing criterion 2>
- [ ] <include relevant technical criteria when non-obvious>
```

**For Epics:**

```markdown
## Overview

<high-level description and business value>

## Success Criteria

- <broad outcome 1>
- <broad outcome 2>

## Child Issues

<!-- Will be populated with sub-issues -->

## Total Story Points

<sum of children>
```

### 7. Create the Issue

```bash
gh issue create \
  --title "[TYPE]-[CATEGORY] Description" \
  --body "<generated body>" \
  --label "<task|story|epic>"
```

### 8. Add to Project Board and Set Fields

Use gh project commands from `docs/claude/operations/GITHUB_CONFIG.md`:

1. Add issue to project: `gh project item-add {{GITHUB_PROJECT_NUMBER}} --owner {{GITHUB_OWNER}} --url <issue-url>`
2. Get the project item ID (GraphQL query in config file)
3. Set fields: Type, Priority, Story Points, Sprint

**Sprint assignment:**

- **Always** assign to **Backlog**. Sprint assignment is handled later by `/start-issue` when implementation begins.
- Do NOT assign to a sprint at creation time — this ensures the Plan-to-Implementation Protocol is followed.

### 9. Epic Cascade (if Type = Epic)

If the issue is an Epic (13+ SP):

1. Break down into Stories (3-8 SP each) and/or Tasks (1-3 SP each)
2. Present breakdown to user for confirmation
3. For each child:
   - Create child issue with `gh issue create`
   - Link as sub-issue (API command in `docs/claude/operations/WORK_ITEMS.md`)
   - Add to project and set fields (Type, Priority, SP, Sprint) using commands from `docs/claude/operations/GITHUB_CONFIG.md`

4. Update epic body with child issue references

### 10. Return Results

Display to user:

- Issue URL(s) created
- Type, Priority, Story Points assigned
- Sprint assignment
- Child issues (if Epic)

---

**IMPORTANT:** Always confirm SP estimate and issue breakdown with user before creating.
