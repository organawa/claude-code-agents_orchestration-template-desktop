---
name: ready-for-testing
description: Mark issue ready for testing after development is complete
---

# Ready for Testing Workflow

Mark an issue as ready for user testing. Runs targeted automated tests (only suites relevant to changed files), then transitions to user testing.

**Usage:** `/ready-for-testing <issue-number>`

**What this does:**
1. Set status to "Automated Tests"
2. Run targeted tests (only suites relevant to files changed in this issue)
3. Update the issue documentation file
4. Merge feature branch to `develop`
5. Set GitHub Project status to "Ready for testing"
6. Propose test protocol with checkboxes
7. Share issue URL
8. **STOP and wait for user**

**Arguments:**
- `$ARGUMENTS` - The GitHub issue number

**References:**
- GitHub field IDs, gh commands: `docs/claude/operations/GITHUB_CONFIG.md`

---

## Workflow

### 1. Set Status to "Automated Tests"

Update issue status to "Automated Tests" on the GitHub Project board using gh project commands from `docs/claude/operations/GITHUB_CONFIG.md`.

### 2. Run Targeted Tests

Run only the test suites **relevant to the files changed** in this issue. Analyze the changed files to determine which suites apply:

| Files changed in… | Run |
|---|---|
| Backend code (API routes, services, models, DB) | Backend tests: `{{TEST_COMMAND_BACKEND}}` |
| Frontend code (components, pages, styles, hooks) | Frontend tests: `{{TEST_COMMAND_FRONTEND}}` |
| Both backend and frontend | Both suites |

**Do NOT run Playwright e2e tests here.** E2E tests run during user testing (`/start-testing`) or before deploy (`/deploy-issue`).

**How to detect relevant suites:**
```bash
# List files changed on this feature branch vs develop
git diff --name-only develop...HEAD
```
- If any file is under backend directories → run backend tests
- If any file is under frontend directories → run frontend tests
- If only config/docs/infra files changed → skip tests, proceed directly

**CRITICAL:** If any targeted tests fail, STOP. Status stays at "Automated Tests". Troubleshoot, fix, and re-run until all pass. Do not proceed with failing tests.

### 3. Update Issue Documentation File

Update the temp documentation file `docs/claude/issues/ISSUE-$ARGUMENTS-*.md`:
- Add development summary (what was done, key decisions)
- List all files changed
- Note any trade-offs or technical debt introduced
- Add testing observations
- Record automated test results

### 4. Merge to Develop
```bash
git checkout develop
git pull origin develop
git merge --no-ff feature/$ARGUMENTS-* -m "Merge feature/$ARGUMENTS: <description>

Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
git push origin develop
```

### 5. Set Status to "Ready for testing"

Update issue status to "Ready for testing" on the GitHub Project board using gh project commands from `docs/claude/operations/GITHUB_CONFIG.md`.

### 6. Propose Test Protocol

Add a comment to the issue with test steps as checkboxes:

```bash
gh issue comment $ARGUMENTS --body "## Test Protocol

### Test Environment
- **Branch:** \`develop\`
- **Local URL:** {{LOCAL_URL}}
- **Prod URL:** {{PROD_URL}}

### Automated Test Results
<list only the suites that were run, with PASSED/FAILED status>
- <Suite>: PASSED

### Manual Test Steps
- [ ] <specific test step 1>
- [ ] <specific test step 2>
- [ ] <verify expected behavior>

### Regression Checks
- [ ] <related feature still works>
- [ ] No console errors

### Expected Results
- <what should happen>

---
Ready for testing on \`develop\`.
When done: \`/start-testing $ARGUMENTS\` to begin, then \`/approve-testing $ARGUMENTS\` if all passes."
```

### 7. Share Issue URL

Display the issue URL to the user:
```
Issue URL: https://github.com/{{GITHUB_OWNER}}/{{GITHUB_REPO}}/issues/$ARGUMENTS
```

### 8. STOP and Wait

**Do NOT:**
- Deploy to production
- Start next issue
- Make any more changes

**Wait for user to:**
- Start testing with `/start-testing $ARGUMENTS`
- Report results
- Approve with `/approve-testing $ARGUMENTS`

---

**This is a STOP checkpoint. Do not proceed past this point without user action.**
