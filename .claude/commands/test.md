description: Run backend, frontend, and e2e tests with summary
allowed-tools: Bash

Run all test suites and provide a summary:

1. Run backend tests: `{{TEST_COMMAND_BACKEND}}`
2. Run frontend checks: `{{TEST_COMMAND_FRONTEND}}`
3. Run Playwright e2e tests: `{{E2E_TEST_COMMAND}}`
4. Summarize:
   - Total tests passed / failed / skipped per suite
   - List any failures with file:line and error message
   - Overall verdict: PASS or FAIL
