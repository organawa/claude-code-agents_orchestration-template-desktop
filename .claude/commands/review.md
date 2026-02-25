description: Review staged or unstaged code changes for quality, security, and bugs
allowed-tools: Bash, Read, Grep, Glob

Review the current code changes. Follow these steps:

1. Run `git diff --cached` to see staged changes. If none, run `git diff` for unstaged changes.
2. For each changed file, review for:
   - **Security**: XSS, SQL injection, command injection, exposed secrets, OWASP top 10
   - **Bugs**: Logic errors, off-by-one, null/undefined handling, race conditions
   - **Quality**: Dead code, unused imports, unclear naming, missing error handling
   - **Project rules**: Check changes against project conventions in CLAUDE.md
3. Output a concise summary with:
   - A severity rating (clean / minor issues / needs attention)
   - Specific issues found with file:line references
   - Suggested fixes if applicable
4. Keep the review focused — don't nitpick style (hooks handle formatting).
