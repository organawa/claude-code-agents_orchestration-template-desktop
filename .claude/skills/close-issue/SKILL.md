---
name: close-issue
description: Complete and close a lightweight issue with documentation consolidation
---

# Close Issue Workflow

Complete a lightweight-tier issue (INFRA, DOCS, GOV, CHORE). This skill handles documentation consolidation and cleanup without the test/merge/deploy cycle.

**Usage:** `/close-issue <issue-number>`

**When to use:** For lightweight issues that don't involve codebase changes. For dev-tier issues, use `/ready-for-testing` then `/deploy-issue` instead.

**What this does:**
1. Verify issue is lightweight tier
2. Update issue documentation file with completion summary
3. Consolidate documentation to Notion (if enabled)
4. Update local context docs if relevant
5. Set GitHub Project status to "Done"
6. Close issue with comment
7. Cleanup issue doc file

**Arguments:**
- `$ARGUMENTS` - The GitHub issue number

**References:**
- GitHub field IDs, gh commands: `docs/claude/operations/GITHUB_CONFIG.md`
- Documentation index: `docs/claude/INDEX.md`

---

## Workflow

### 1. Verify Lightweight Tier

Fetch issue details and check the category:
```bash
gh issue view $ARGUMENTS --json number,title,body,labels
```

Parse the `[CATEGORY]` from the title. Lightweight categories: `INFRA`, `DOCS`, `GOV`, `CHORE`.

**If the issue is a Dev-tier category** (FEAT, BUG, ENH, etc.):
- Warn the user: "This is a dev-tier issue. Use `/ready-for-testing` then `/deploy-issue` instead."
- STOP — do not proceed.

### 2. Update Issue Documentation File

Read and update the temp documentation file `docs/claude/issues/ISSUE-$ARGUMENTS-*.md`:
- Fill in the Deliverables section with what was produced
- Add completion notes to Progress Notes
- Confirm all Completion Criteria are met

<!-- NOTION_START -->
### 3. Consolidate Documentation to Notion

Use Notion MCP tools to update topic-based documentation in the Notion database.

**Documentation is organized by topic, not by issue.** Only document if the work introduces knowledge worth preserving (e.g., new infra setup, governance decisions). Most `[CHORE]` issues won't need documentation.

#### 3a. Assess Documentation Need

Read the `## Notion Documentation Plan` from the issue doc (`docs/claude/issues/ISSUE-$ARGUMENTS-*.md`). If the plan says no documentation is needed, skip to step 4.

#### 3b. Search for Existing Topic Doc

```
notion-search: query matching the topic/feature area
```

**Always search first.** Only create a new page if no existing doc covers this topic.

#### 3c. Update Existing Topic Doc or Create New

**If an existing topic doc is found (preferred path):**
1. Fetch the existing page content
2. **Add** new information in the appropriate section
3. **Update** existing information if behavior changed
4. **Remove** outdated information that is no longer accurate
5. Increment version and update version history table

**If a new topic doc is needed:**

| Issue Category | Notion Category | Doc Type | Default Audience |
|---------------|----------------|----------|-----------------|
| `[INFRA]` | INFRA | How-To | Operations |
| `[DOCS]` | DOCS | — | — |
| `[GOV]` | GOV | Reference | Stakeholders |
| `[CHORE]` | CHORE | Reference | Developers |

```
notion-create-pages:
  parent: { data_source_id: "{{NOTION_DATABASE_ID}}" }
  properties:
    Name: "<Topic Title>"
    Category: <mapped category>
    Doc Type: <mapped doc type>
    Version: "1.0"
    Audience: <mapped audience>
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

**Required properties checklist:**
- [ ] Version (text, e.g., "1.0")
- [ ] Audience (multi-select)
- [ ] Doc Type (select)
- [ ] Version history callout + table at top of content
<!-- NOTION_END -->

### 4. Update Local Context Docs (if relevant)

Review what changed and update relevant `docs/claude/` files:

| If this changed... | Update this file |
|---------------------|-----------------|
| System components, integrations, data flow | `docs/claude/context/ARCHITECTURE.md` |
| Dev/prod URLs, ports, env vars | `docs/claude/context/ENVIRONMENTS.md` |
| Docker, nginx, deployment | `docs/claude/context/INFRASTRUCTURE.md` |
| Code conventions, new patterns | `docs/claude/context/CODE_PATTERNS.md` |
| GitHub config, field IDs | `docs/claude/operations/GITHUB_CONFIG.md` |
| Work item definitions | `docs/claude/operations/WORK_ITEMS.md` |
| New troubleshooting knowledge | `docs/claude/operations/TROUBLESHOOTING.md` |

### 5. Set Status to "Done"

Update issue status to "Done" on the GitHub Project board using gh project commands from `docs/claude/operations/GITHUB_CONFIG.md`.

### 6. Close Issue

```bash
gh issue close $ARGUMENTS --comment "## Completed

<summary of what was done>

Documentation consolidated."
```

### 7. Cleanup

Delete the temporary issue documentation file:
```bash
rm docs/claude/issues/ISSUE-$ARGUMENTS-*.md
```

---

**NOTE:** This skill is for lightweight-tier issues only. Dev-tier issues must go through `/ready-for-testing` then `/deploy-issue`.
