description: Pre-deployment checklist before merging to main
allowed-tools: Bash, Read, Glob

Run through the deployment readiness checklist:

1. **Tests**: Run `{{TEST_COMMAND_BACKEND}}` and `{{TEST_COMMAND_FRONTEND}}`
2. **Branch state**: Verify current branch is `develop` and is up to date with remote (`git fetch origin && git rev-list HEAD..origin/develop --count`)
3. **Uncommitted changes**: Check `git status --porcelain` — warn if any uncommitted changes exist
4. **Protected data**: Check if `{{PROTECTED_DATA_DIR}}` has uncommitted changes that need backup
5. **Pending issues**: Check for any `docs/claude/issues/ISSUE-*.md` temp docs (should be cleaned up before deploy)
6. **Release notes**: Check if release notes have been updated

Present results as a checklist with pass/fail for each item. End with a clear GO / NO-GO recommendation.
