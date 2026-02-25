---
name: sprint-retro
description: Create sprint retrospective and update learnings
---

# Sprint Retrospective Workflow

Conduct a sprint retrospective and update project documentation with learnings.

**Usage:** `/sprint-retro [sprint-name]`

**What this does:**
1. Gather sprint metrics (velocity, completed issues)
2. Identify recurring issues
3. Update `CLAUDE.md` with new rules/patterns if needed
4. Create Notion retrospective page (if enabled)

**Arguments:**
- `$ARGUMENTS` - Optional sprint name (e.g., "Sprint 5" or "2024-W08")

**Workflow:**

## 1. Gather Sprint Metrics

### Completed Issues
```bash
gh issue list --state closed --json number,title,labels,closedAt \
  --search "closed:>=$(date -d '7 days ago' +%Y-%m-%d)"
```

### Story Points Completed
Check GitHub Project for completed story points in the sprint.

## 2. Reflect on Sprint

Ask user (or analyze issues):
- **What went well?** (3-5 items)
- **What didn't work?** (3-5 items)
- **Key learnings** (2-3 items)
- **Action items** (specific, measurable)

## 3. Identify Recurring Issues

If same problem appears in multiple sprints:
- **Root cause analysis:** Why does this keep happening?
- **Process change:** What rule/check would prevent it?

## 4. Update CLAUDE.md (if needed)

If recurring issues found, update `CLAUDE.md`:
- Add to Rules section
- Update debugging protocol
- Add new conventions

<!-- NOTION_START -->
## 5. Create Notion Retrospective Page

Use Notion MCP tools (load via ToolSearch first) to create a page in the Documentation database:

```
notion-create-pages:
  parent: { data_source_id: "{{NOTION_DATABASE_ID}}" }
  properties:
    Name: "[GOV] Sprint Retrospective — <sprint-name>"
    Category: GOV
    Doc Type: Explanation
    Audience: '["Stakeholders", "Developers"]'
    Status: Published
    Last Updated: <today>
  content: Sprint metrics, learnings, and action items
```
<!-- NOTION_END -->

## 6. Commit Retrospective
```bash
git add CLAUDE.md docs/
git commit -m "docs: add sprint retrospective and update rules

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
git push origin develop
```

---

**Best Practice:** Run this at the end of every sprint.
