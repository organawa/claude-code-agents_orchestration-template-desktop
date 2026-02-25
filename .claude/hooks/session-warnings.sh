#!/bin/bash
# UserPromptSubmit hook — non-blocking warnings about environment state
# Pure warnings (exit 0 always), never blocks the workflow

INPUT=$(cat)

if ! command -v jq &> /dev/null; then
  exit 0
fi

CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)

# Warn about uncommitted protected data on develop
if [ "$CURRENT_BRANCH" = "develop" ]; then
  USER_DATA_CHANGES=$(git status --porcelain 2>/dev/null | grep -E "{{PROTECTED_DATA_PATTERNS}}" || true)
  if [ -n "$USER_DATA_CHANGES" ]; then
    echo "WARNING: Uncommitted data changes on develop. Never use git stash/reset --hard. Backup first: cp -r {{PROTECTED_DATA_DIR}} {{PROTECTED_DATA_DIR}}.backup" >&2
  fi
fi

# Warn about multiple feature branches
FEATURE_BRANCHES=$(git branch 2>/dev/null | grep -c "feature/" || echo "0")
if [ "$FEATURE_BRANCHES" -gt 1 ]; then
  echo "WARNING: $FEATURE_BRANCHES feature branches detected. Work on ONE issue at a time." >&2
fi

exit 0
