#!/bin/bash
# PreToolUse hook for Bash — protects user data and enforces git safety
# Exit 0: allow, Exit 2: block

INPUT=$(cat)

if ! command -v jq &> /dev/null; then
  exit 0
fi

COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

if [ -z "$COMMAND" ]; then
  exit 0
fi

PROJECT_ROOT=$(git rev-parse --show-toplevel 2>/dev/null)

# ============================================================
# PROTECT USER DATA — block destructive git ops when data is dirty
# ============================================================
if echo "$COMMAND" | grep -qE '^\s*git\s+(stash|reset\s+--hard|checkout\s+\.)'; then
  if [ -n "$PROJECT_ROOT" ]; then
    USER_DATA_DIRTY=$(git status --porcelain -- "$PROJECT_ROOT/{{PROTECTED_DATA_DIR}}" 2>/dev/null | head -1)
    if [ -n "$USER_DATA_DIRTY" ]; then
      echo '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"{{PROTECTED_DATA_DIR}} has uncommitted changes. Backup first: cp -r {{PROTECTED_DATA_DIR}} {{PROTECTED_DATA_DIR}}.backup"}}'
      exit 0
    fi
  fi
fi

# ============================================================
# GIT COMMIT GUARDS
# ============================================================
if echo "$COMMAND" | grep -qE '^\s*git\s+commit|&&\s*git\s+commit'; then

  # Block committing protected data files
  STAGED_USER_DATA=$(git diff --cached --name-only 2>/dev/null | grep -E "{{PROTECTED_DATA_PATTERNS}}" || true)
  if [ -n "$STAGED_USER_DATA" ]; then
    echo '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"Protected data files are staged for commit. Unstage with: git reset HEAD <file>"}}'
    exit 0
  fi

  # Block committing sensitive files
  STAGED_SENSITIVE=$(git diff --cached --name-only 2>/dev/null | grep -E '\.env$|credentials\.json|secrets\.|.*\.key$|.*\.pem$' || true)
  if [ -n "$STAGED_SENSITIVE" ]; then
    echo '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"Sensitive files staged for commit. Unstage them first."}}'
    exit 0
  fi

  # Warn (not block) about direct commits to develop
  CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
  if [ "$CURRENT_BRANCH" = "develop" ]; then
    echo '{"hookSpecificOutput":{"hookEventName":"PreToolUse","additionalContext":"Warning: committing directly to develop. Use a feature branch for multi-commit work."}}'
    exit 0
  fi
fi

# ============================================================
# GIT PUSH GUARDS
# ============================================================
if echo "$COMMAND" | grep -qE '^\s*git\s+push|&&\s*git\s+push'; then
  # Block force push to main/master
  if echo "$COMMAND" | grep -qE '\-\-force|\-f\s'; then
    CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
    if echo "$COMMAND" | grep -qE 'push\b.*\bmain\b|push\b.*\bmaster\b' || \
       [ "$CURRENT_BRANCH" = "main" ] || [ "$CURRENT_BRANCH" = "master" ]; then
      echo '{"hookSpecificOutput":{"hookEventName":"PreToolUse","permissionDecision":"deny","permissionDecisionReason":"Force push to main/master is blocked."}}'
      exit 0
    fi
  fi

  # Warn when pushing to main (triggers deploy)
  CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD 2>/dev/null)
  if [ "$CURRENT_BRANCH" = "main" ]; then
    echo '{"hookSpecificOutput":{"hookEventName":"PreToolUse","additionalContext":"Pushing to main will trigger deployment. Ensure user has approved."}}'
    exit 0
  fi
fi

# All checks passed — allow
exit 0
