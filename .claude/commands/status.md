description: Show current branch, git state, and active issue context
allowed-tools: Bash, Read, Glob

Show a quick project status dashboard:

1. Run `git branch --show-current` and `git status --short`
2. Show last 3 commits: `git log --oneline -3`
3. Check for any `docs/claude/issues/ISSUE-*.md` files to identify the active issue
4. If an active issue doc exists, show its title and current status
5. Check if dev servers are likely running: `lsof -i :{{DEV_PORT_BACKEND}} 2>/dev/null | head -2` and `lsof -i :{{DEV_PORT_FRONTEND}} 2>/dev/null | head -2`
6. Present everything in a compact dashboard format
