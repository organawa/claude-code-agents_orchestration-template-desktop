---
name: approve-testing
description: Mark issue as tested and ready for production deployment
---

# Approve Testing Workflow

Mark an issue as tested and approved, transitioning to "Ready for Prod" status.

**Usage:** `/approve-testing <issue-number>`

**Arguments:**
- `$ARGUMENTS` - The GitHub issue number

---

## Workflow

### 1. Set Status to "Ready for Prod"

Update issue status to "Ready for Prod" on the GitHub Project board using gh project commands from `docs/claude/operations/GITHUB_CONFIG.md`.

### 2. Add Approval Comment

```bash
gh issue comment $ARGUMENTS --body "## Testing Approved

Testing completed and approved. Issue is now **Ready for Prod**.

Deploy with: \`/deploy-issue $ARGUMENTS\`"
```

### 3. Confirm to User

Display:
- Status is set to "Ready for Prod"
- Issue URL: `https://github.com/{{GITHUB_OWNER}}/{{GITHUB_REPO}}/issues/$ARGUMENTS`
- Use `/deploy-issue $ARGUMENTS` when ready to deploy

**STOP — Do not deploy automatically. Wait for user to explicitly request deployment.**

---

**NOTE:** This transitions the issue from "Being tested" to "Ready for Prod" in the project board.
