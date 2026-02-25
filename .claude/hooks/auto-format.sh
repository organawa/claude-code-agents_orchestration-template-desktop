#!/bin/bash
# PostToolUse hook for Edit|Write — auto-formats code after edits
# Exit 0 always — formatting errors should never block edits

INPUT=$(cat)

if ! command -v jq &> /dev/null; then
  exit 0
fi

EDITED_FILE=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

if [ -z "$EDITED_FILE" ] || [ ! -f "$EDITED_FILE" ]; then
  exit 0
fi

case "$EDITED_FILE" in
  *.py)
    if command -v black &> /dev/null; then
      black -q "$EDITED_FILE" 2>/dev/null
    fi
    ;;
  *.ts|*.js|*.svelte|*.tsx|*.jsx|*.vue)
    FRONTEND_DIR="$(git rev-parse --show-toplevel 2>/dev/null)/{{FRONTEND_DIR}}"
    if [ -f "$FRONTEND_DIR/node_modules/.bin/prettier" ]; then
      "$FRONTEND_DIR/node_modules/.bin/prettier" --write "$EDITED_FILE" 2>/dev/null
    elif command -v prettier &> /dev/null; then
      prettier --write "$EDITED_FILE" 2>/dev/null
    fi
    ;;
  # Add additional formatters below
esac

exit 0
