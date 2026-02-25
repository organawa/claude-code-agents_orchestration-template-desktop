---
name: setup-notion
description: Create the Notion Documentation database with full schema for this project
---

# Setup Notion Documentation Database

Create a Documentation database in Notion with all required properties for the issue lifecycle skills.

**Usage:** `/setup-notion [parent-page-url]`

**When to use:** After running `setup.sh`, when Notion integration is enabled but no database exists yet.

**Arguments:**
- `$ARGUMENTS` - (Optional) URL or ID of a Notion page to create the database under. If omitted, creates as a workspace-level page.

---

## Workflow

### 1. Check Current State

Read `docs/claude/operations/GITHUB_CONFIG.md` or `CLAUDE.md` to find the current `NOTION_DATABASE_ID` value.

If it's already a valid ID (not `SETUP_PENDING` or `NOT_CONFIGURED`), ask the user if they want to create a new one or keep the existing one.

### 2. Create the Documentation Database

Use Notion MCP tools (load via ToolSearch first).

**If `$ARGUMENTS` is provided** (parent page URL/ID):

```
notion-create-pages:
  parent: { page_id: "<parent-page-id>" }
  pages:
    - properties:
        title: "Documentation"
```

Then fetch the created page to get its ID, and create the database under it.

**If no parent specified**, create as a workspace-level database.

### 3. Create Database with Schema

Use `notion-create-database` or create the database via the Notion MCP tools with this schema:

**Properties to create:**

| Property | Type | Options |
|----------|------|---------|
| Name | Title | (default title property) |
| Category | Select | FEAT, ENH, BUG, UI, UX, SEC, PERF, REFAC, INFRA, DOCS, GOV, CHORE |
| Doc Type | Select | Tutorial, How-To, Reference, Explanation |
| Version | Text | — |
| Audience | Multi-select | Developers, End Users, Operations, Stakeholders |
| Status | Select | Draft, In Review, Published, Archived |
| Related Issue | URL | — |
| Last Updated | Date | — |
| Component | Multi-select | (empty, user adds per project) |
| Tags | Multi-select | (empty, user adds per project) |
| Review Cadence | Select | Per Release, Quarterly, On Change, None |

### 4. Get the Data Source ID

After creating the database, fetch it to get the data source ID:

```
notion-fetch: <database-url>
```

Look for the `collection://` URL in the response. The data source ID is the UUID after `collection://`.

### 5. Update Project Files

Replace `SETUP_PENDING` (or `NOT_CONFIGURED`) with the actual data source ID in all files:

```bash
# Find and replace in all relevant files
grep -rl "SETUP_PENDING\|NOT_CONFIGURED" . --include='*.md' | head -20
```

Use the Edit tool to replace the placeholder with the actual ID in:
- `.claude/skills/deploy-issue/SKILL.md`
- `.claude/skills/close-issue/SKILL.md`
- `.claude/skills/sprint-retro/SKILL.md`

### 6. Create Master TOC Page

Create an initial "Documentation — Master Table of Contents" page in the database:

```
notion-create-pages:
  parent: { data_source_id: "<new-data-source-id>" }
  pages:
    - properties:
        Name: "Documentation — Master Table of Contents"
        Category: "DOCS"
        Doc Type: "Reference"
        Version: "1.0"
        Audience: '["Developers", "Stakeholders"]'
        Status: "Published"
      content: |
        This is the master index for all project documentation.

        Documents are created automatically during the issue lifecycle:
        - `/deploy-issue` creates docs for dev-tier issues
        - `/close-issue` creates docs for lightweight-tier issues
        - `/sprint-retro` creates retrospective docs
```

### 7. Confirm to User

Display:
- Database URL
- Data source ID
- Number of files updated
- Reminder: "Your Notion integration is ready. Documentation will be created automatically during `/deploy-issue`, `/close-issue`, and `/sprint-retro`."

---

**NOTE:** This skill only needs to be run once per project, after initial setup.
