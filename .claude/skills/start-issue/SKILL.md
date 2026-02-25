---
name: start-issue
description: Start working on a GitHub issue following the project workflow
---

# Start Issue Workflow

Start working on a GitHub issue. This skill automates the "START" phase of the issue lifecycle.

**Usage:** `/start-issue <issue-number>`

**What this does:**
1. Fetch issue details from GitHub
2. Detect workflow tier (Dev or Lightweight) from category prefix
3. Set GitHub Project status to "Dev Started"
4. **Dev tier only:** Create feature branch from `develop`
5. Create temporary documentation file for the issue
6. Add comment to issue with planned approach
7. **Dev tier only:** Confirm dev servers are running

**Arguments:**
- `$ARGUMENTS` - The GitHub issue number (e.g., `123`)

**References:**
- GitHub field IDs, gh commands: `docs/claude/operations/GITHUB_CONFIG.md`
- Workflow tier mapping: see "Workflow Tier Mapping" section in `docs/claude/operations/GITHUB_CONFIG.md`

---

## Workflow

### 1. Fetch Issue Details
```bash
gh issue view $ARGUMENTS --json number,title,body,labels
```

### 2. Detect Workflow Tier

Parse the `[CATEGORY]` from the issue title (pattern: `\[([A-Z]+)\]`) and determine the workflow tier:

| Tier | Categories | Workflow |
|------|-----------|----------|
| **Dev** | `FEAT`, `BUG`, `ENH`, `REFAC`, `PERF`, `SEC`, `UI`, `UX` | Full lifecycle: branch, test, merge, deploy |
| **Lightweight** | `INFRA`, `DOCS`, `GOV`, `CHORE` | Simplified: status, doc, comment, then `/close-issue` |

Display the detected tier to the user:
> **Workflow tier:** Dev / Lightweight — based on category `[CATEGORY]`

If the category is not recognized, default to **Dev** tier.

### 3. Analyze and Plan Approach
- Read the issue description
- Identify affected files/components (Dev) or deliverables (Lightweight)
- Draft implementation approach

### 4. Set Status to "Dev Started"

Update issue status to "Dev Started" on the GitHub Project board using gh project commands from `docs/claude/operations/GITHUB_CONFIG.md`.

### 4b. Assign to Current Sprint

Read Sprint IDs from `docs/claude/operations/GITHUB_CONFIG.md`.

1. Set this issue's Sprint field to **Sprint 1** (or the current active sprint).
2. **If this is the first `/start-issue` from a batch of newly created plan issues:** also move all other Backlog issues that belong to the same plan to Sprint 1. To detect sibling issues, list all project items in Backlog status and move them to Sprint 1.

```bash
# Set sprint on current issue
gh project item-edit \
  --id "<ITEM_ID>" \
  --project-id "{{GITHUB_PROJECT_ID}}" \
  --field-id "{{SPRINT_FIELD_ID}}" \
  --single-select-option-id "<SPRINT_1_ID>"
```

**Sprint ID lookup:** Use the Sprint 1 ID from `docs/claude/operations/GITHUB_CONFIG.md`.

### 5. Create Feature Branch (Dev tier only)

**Skip this step entirely for Lightweight tier.**

```bash
git checkout develop
git pull origin develop
git checkout -b feature/$ARGUMENTS-<short-description>
```

Branch naming: `feature/<issue-number>-<short-description>`
- Example: `feature/123-fix-dropdown`

### 6. Create Issue Documentation File

Create a temporary working document for tracking implementation details:

**File:** `docs/claude/issues/ISSUE-$ARGUMENTS-<slug>.md`

Generate the slug from the issue title:
```bash
ISSUE_TITLE=$(gh issue view $ARGUMENTS --json title -q .title)
SLUG=$(echo "$ISSUE_TITLE" | tr '[:upper:]' '[:lower:]' | tr ' ' '-' | tr -cd '[:alnum:]-' | cut -c1-30)
```

#### Dev Tier Template:
```markdown
# Issue #<number> - <title>

## Issue Details
- **URL:** https://github.com/{{GITHUB_OWNER}}/{{GITHUB_REPO}}/issues/<number>
- **Type:** <Task/Story/Epic>
- **Category:** <[FEAT]/[BUG]/etc.>
- **Workflow:** Dev
- **Branch:** feature/<number>-<slug>
- **Started:** <date>
- **Priority:** <P1-P4>
- **Story Points:** <SP>

## Implementation Plan
<Approach determined in step 3>

## Development Notes
<!-- Updated during development with decisions, trade-offs, learnings -->

## Files Changed
<!-- Updated as development progresses -->

## Testing Notes
<!-- Pre-testing observations, edge cases to verify -->

<!-- NOTION_START -->
## Notion Documentation Plan
<!-- Topic-based: which existing topic doc to update, or new topic to create -->
- **Needs Notion doc?** <Yes / No — Tasks that are part of a Story/Epic usually don't>
- **Topic:** <topic name, e.g., "Authentication", "Payment System">
- **Action:** <Update existing topic doc / Create new topic doc>
- **What to document:** <brief description of what info to add/update/remove>
<!-- NOTION_END -->
```

#### Lightweight Tier Template:
```markdown
# Issue #<number> - <title>

## Issue Details
- **URL:** https://github.com/{{GITHUB_OWNER}}/{{GITHUB_REPO}}/issues/<number>
- **Type:** <Task/Story/Epic>
- **Category:** <[INFRA]/[DOCS]/etc.>
- **Workflow:** Lightweight
- **Started:** <date>
- **Priority:** <P1-P4>
- **Story Points:** <SP>

## Implementation Plan
<Approach determined in step 3>

## Deliverables
<!-- What will be produced by this issue -->

## Progress Notes
<!-- Updated during work with decisions, trade-offs, learnings -->

## Completion Criteria
<!-- What must be true for this issue to be considered done -->

<!-- NOTION_START -->
## Notion Documentation Plan
<!-- Topic-based: only document if this introduces knowledge worth preserving -->
- **Needs Notion doc?** <Yes / No — most CHORE issues don't need documentation>
- **Topic:** <topic name if yes>
- **Action:** <Update existing topic doc / Create new topic doc>
- **What to document:** <brief description of what info to add/update/remove>
<!-- NOTION_END -->
```

This file is used throughout the issue lifecycle and consolidated to Notion documentation during completion.

### 7. Comment on Issue

#### Dev Tier Comment:
```bash
gh issue comment $ARGUMENTS --body "## Dev Started

**Branch:** \`feature/$ARGUMENTS-<slug>\`

### Implementation Approach
<approach-description>

### Files to be Modified
- <file list>

### Expected Changes
- <change list>"
```

#### Lightweight Tier Comment:
```bash
gh issue comment $ARGUMENTS --body "## Dev Started (Lightweight)

### Approach
<approach-description>

### Deliverables
- <deliverable list>

### Completion Criteria
- <criteria list>

---
_Lightweight workflow — no feature branch. Close with \`/close-issue $ARGUMENTS\` when done._"
```

### 8. Verify Dev Servers (Dev tier only)

**Skip this step entirely for Lightweight tier.**

Check if dev servers are running:
```bash
lsof -i :{{DEV_PORT_FRONTEND}} -i :{{DEV_PORT_BACKEND}} | grep LISTEN
```

If not running, ask user: "Start dev servers? (Yes/No)"

---

**CRITICAL:** This must be the FIRST step when starting any issue. Never skip this workflow.
