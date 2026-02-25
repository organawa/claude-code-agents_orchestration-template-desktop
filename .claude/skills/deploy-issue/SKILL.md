---
name: deploy-issue
description: Deploy approved changes to production with documentation consolidation
disable-model-invocation: true
---

# Deploy to Production Workflow

Deploy tested and approved changes to production. **Only use after user explicitly approves.**

**Usage:** `/deploy-issue <issue-number or "all">`

**Prerequisites:**
- Issue status is "Ready for Prod"
- User has tested and approved
- User has explicitly said "deploy", "prod", or given approval

**What this does:**
1. Check prerequisites
2. Update local context documentation (`docs/claude/`)
3. Consolidate issue documentation to Notion (if enabled)
4. Commit documentation updates
5. Run full test suite (backend + frontend + e2e) as final regression gate
6. Merge `develop` to `main`
7. Trigger deployment
8. Run health checks
9. Set status to "Done" and close issue
10. Cleanup temp files and feature branch

**Arguments:**
- `$ARGUMENTS` - Issue number, multiple numbers (space-separated), or "all" for all Ready for Prod issues

**References:**
- GitHub field IDs, gh commands: `docs/claude/operations/GITHUB_CONFIG.md`
- Documentation index: `docs/claude/INDEX.md`

---

## Workflow

### 1. Check Prerequisites

Verify:
- Current branch is `develop`
- All changes are committed and pushed
- Issue status is "Ready for Prod"

```bash
gh issue view $ARGUMENTS --json state,title,labels
```

If `$ARGUMENTS` is "all", find all issues in "Ready for Prod" status from the project board.

### 2. Update Local Context Documentation

Review what changed in this issue and update the relevant `docs/claude/` files:

#### Read Issue Documentation
```bash
ls docs/claude/issues/ISSUE-$ARGUMENTS-*.md
```

Read the file to extract implementation details, decisions, and files changed.

#### Update Context Files (if relevant)

| If this changed... | Update this file |
|---------------------|-----------------|
| System components, integrations, data flow | `docs/claude/context/ARCHITECTURE.md` |
| API endpoints, data models, schemas | `docs/claude/context/API_REFERENCE.md` |
| Dev/prod URLs, ports, env vars | `docs/claude/context/ENVIRONMENTS.md` |
| Docker, nginx, deployment | `docs/claude/context/INFRASTRUCTURE.md` |
| Code conventions, new patterns | `docs/claude/context/CODE_PATTERNS.md` |
| GitHub config, field IDs | `docs/claude/operations/GITHUB_CONFIG.md` |
| Work item definitions | `docs/claude/operations/WORK_ITEMS.md` |
| New troubleshooting knowledge | `docs/claude/operations/TROUBLESHOOTING.md` |

#### Update INDEX.md
Update the "Last Updated" dates for any files that were modified.

<!-- NOTION_START -->
### 3. Consolidate Documentation to Notion

Use Notion MCP tools to update topic-based documentation in the Notion database.

**Documentation is organized by topic, not by issue.** The goal is to maintain a structured, living knowledge base.

#### 3a. Assess Documentation Need

Not every issue requires Notion documentation. Check:

| Issue type | Document? |
|---|---|
| **Task** (T-) that is part of a Story/Epic | **No** — documentation happens when the parent Story/Epic completes |
| **Standalone Task** (T-) | Only if it introduces noteworthy knowledge |
| **Story** (S-) | **Yes** — consolidate to the relevant topic doc |
| **Epic** (E-) | **Yes** — may warrant a new topic doc or major update |

If no documentation is needed, skip to step 4.

#### 3b. Read the Notion Documentation Plan

From the issue doc (`docs/claude/issues/ISSUE-$ARGUMENTS-*.md`), read the `## Notion Documentation Plan` section.

#### 3c. Search for Existing Topic Doc

```
notion-search: query matching the topic/feature area (e.g., "Authentication", "Payment System")
```

**Always search first.** Only create a new page if no existing doc covers this topic.

#### 3d. Update Existing Topic Doc or Create New

**If an existing topic doc is found (preferred path):**
1. Fetch the existing page content
2. Identify the right section to update (or add a new section)
3. **Add** new information in the appropriate section
4. **Update** existing information if behavior changed
5. **Remove** outdated information that is no longer accurate
6. Increment version in properties (e.g., `1.0` → `1.1`)
7. Update the version history table with a row describing this change
8. Update Last Modified date in the callout and properties

**If a new topic doc is needed (no existing doc covers this topic):**

Use a descriptive topic name, NOT the issue title.

```
notion-create-pages:
  parent: { data_source_id: "{{NOTION_DATABASE_ID}}" }
  properties:
    Name: "<Topic Title>"
    Category: <mapped category>
    Doc Type: <mapped doc type>
    Version: "1.0"
    Audience: <mapped audience as JSON array, e.g. '["Developers"]'>
    Status: Published
    Last Updated: <today>
  content: |
    <callout icon="clipboard" color="blue_bg">
    **Created:** <today> | **Last Modified:** <today> | **Version:** 1.0
    </callout>

    ## Version History

    <table header-row="true">
    <tr><td>Version</td><td>Date</td><td>Changes</td></tr>
    <tr><td>1.0</td><td><today></td><td>Initial creation from #$ARGUMENTS</td></tr>
    </table>

    ---

    <structured content organized by sections>
```

#### Category to Notion Properties Mapping

| Issue Category | Notion Category | Doc Type | Default Audience |
|---------------|----------------|----------|-----------------|
| `[FEAT]` | FEAT | How-To or Reference | Developers, End Users |
| `[ENH]` | ENH | Reference | Developers |
| `[BUG]` | BUG | Explanation | Developers |
| `[UI]`, `[UX]` | UI / UX | Reference | Developers, End Users |
| `[SEC]` | SEC | Reference | Developers, Operations |
| `[PERF]` | PERF | Explanation | Developers |
| `[REFAC]` | REFAC | Explanation | Developers |
| `[INFRA]` | INFRA | How-To | Operations |
| `[DOCS]` | DOCS | — | — |
| `[GOV]` | GOV | Reference | Stakeholders |
| `[CHORE]` | CHORE | Reference | Developers |

**Required properties checklist (every Notion page must have):**
- [ ] Version (text, e.g., "1.0")
- [ ] Audience (multi-select: Developers, End Users, Operations, Stakeholders)
- [ ] Doc Type (select: Tutorial, How-To, Reference, Explanation)
- [ ] Version history callout + table at top of content
<!-- NOTION_END -->

### 4. Commit Documentation
```bash
git add docs/
git commit -m "docs: update documentation for #$ARGUMENTS

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
git push origin develop
```

### 5. Run Full Test Suite

Before merging to main, run **all** test suites as a final regression gate:

```bash
{{TEST_COMMAND_BACKEND}}
{{TEST_COMMAND_FRONTEND}}
{{E2E_TEST_COMMAND}}
```

**CRITICAL:** If any tests fail, STOP. Do NOT merge to main. Fix the issue on `develop`, re-run tests, and only proceed when all suites pass.

### 6. Merge to Main
```bash
git checkout main
git pull origin main
git merge develop -m "Merge develop to main: Issue #$ARGUMENTS

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
git push origin main
```

### 7. Trigger Deployment
```bash
{{DEPLOY_COMMAND}}
```

### 8. Run Health Checks

```bash
{{HEALTH_CHECK_COMMAND}}
```

Verify deployment was successful. Check GitHub Actions workflow status:
```bash
gh run list --limit 1 --json status,conclusion \
  --jq '.[0] | "\(.status) - \(.conclusion)"'
```

**If any health check fails:** Report to user, do NOT close the issue, do NOT delete temp files. Investigate and fix first.

### 9. Set Status to "Done" and Close Issue

Update issue status to "Done" on the GitHub Project board using gh project commands from `docs/claude/operations/GITHUB_CONFIG.md`.

```bash
gh issue close $ARGUMENTS --comment "Deployed to production. Documentation updated."
```

### 10. Cleanup

#### Delete Issue Documentation Files
```bash
rm docs/claude/issues/ISSUE-$ARGUMENTS-*.md
```

#### Delete Feature Branch
```bash
git branch -d feature/$ARGUMENTS-*
git push origin --delete feature/$ARGUMENTS-*
```

#### Switch back to develop
```bash
git checkout develop
```

---

**IMPORTANT:** Only run this after explicit user approval. Never deploy automatically.
