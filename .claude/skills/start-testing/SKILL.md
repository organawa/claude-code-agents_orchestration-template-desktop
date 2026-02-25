---
name: start-testing
description: Set issue to Being Tested status and remind user of test protocol
---

# Start Testing Workflow

Transition an issue to "Being Tested" status when the user begins testing. Offers manual or Playwright-automated testing.

**Usage:** `/start-testing <issue-number>`

**Arguments:**
- `$ARGUMENTS` - The GitHub issue number

---

## Workflow

### 1. Set Status to "Being Tested"

Update issue status to "Being Tested" on the GitHub Project board using gh project commands from `docs/claude/operations/GITHUB_CONFIG.md`.

### 2. Fetch and Display Test Protocol

Retrieve the test protocol from the issue comments:
```bash
gh issue view $ARGUMENTS --comments --json comments \
  --jq '.comments[] | select(.body | contains("Test Protocol")) | .body'
```

Display the test protocol to the user.

### 3. Provide Testing Information

- **Issue URL:** `https://github.com/{{GITHUB_OWNER}}/{{GITHUB_REPO}}/issues/$ARGUMENTS`
- **Develop branch:** Ensure user is testing on `develop`
- **Local dev URL:** {{LOCAL_URL}}
- **Production URL:** {{PROD_URL}} (if applicable)

### 4. Ask Testing Method

Ask the user: **"How do you want to perform the test protocol?"**

- **Manual** — User tests by hand following the test protocol checkboxes. Display the steps and let them proceed.
- **Playwright** — Claude generates Playwright e2e tests from the test protocol steps, writes them to `tests/e2e/issue-$ARGUMENTS.spec.ts`, runs them with `{{E2E_TEST_COMMAND}}`, and reports results.

#### If Playwright is chosen:

1. Parse the "Manual Test Steps" from the test protocol
2. Generate a Playwright test file at `tests/e2e/issue-$ARGUMENTS.spec.ts` that implements each test step
3. Run the tests:
```bash
{{E2E_TEST_COMMAND}} tests/e2e/issue-$ARGUMENTS.spec.ts
```
4. Report results to the user
5. If all tests pass, ask user if they want to also run a quick manual check or proceed to `/approve-testing`
6. If any test fails, report the failure and investigate

### 5. Remind User

After testing:
- If everything passes: use `/approve-testing $ARGUMENTS`
- If issues found: report them and development resumes

---

**NOTE:** This transitions the issue from "Ready for testing" to "Being tested" in the project board.
