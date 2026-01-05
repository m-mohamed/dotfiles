#!/bin/bash
# install.sh - Install Claude hooks to a project
# Usage: install.sh <project-path>
#
# Copies project-settings.json to <project>/.claude/settings.json
# This enables Claude Code hooks for that project.

set -euo pipefail

PROJECT="${1:-}"

if [[ -z "$PROJECT" ]]; then
  echo "Usage: install.sh <project-path>"
  echo "Example: install.sh ~/myproject"
  exit 1
fi

# Expand ~ if present
PROJECT="${PROJECT/#\~/$HOME}"

if [[ ! -d "$PROJECT" ]]; then
  echo "Error: Directory does not exist: $PROJECT"
  exit 1
fi

# Get the directory where this script lives
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE="$SCRIPT_DIR/project-settings.json"

if [[ ! -f "$TEMPLATE" ]]; then
  echo "Error: Template not found: $TEMPLATE"
  exit 1
fi

# Create .claude directory if it doesn't exist
mkdir -p "$PROJECT/.claude"

# Check if settings.json already exists
TARGET="$PROJECT/.claude/settings.json"
if [[ -f "$TARGET" ]]; then
  echo "Warning: $TARGET already exists"
  echo "Backing up to $TARGET.bak"
  cp "$TARGET" "$TARGET.bak"
fi

# Copy template
cp "$TEMPLATE" "$TARGET"

echo "Installed Claude hooks to $TARGET"
echo ""
echo "Hooks enabled:"
echo "  - SessionStart: idle status"
echo "  - UserPromptSubmit: working status"
echo "  - PermissionRequest: attention status + notification"
echo "  - Notification: attention status + notification"
echo "  - Stop: idle status + notification"
echo ""
echo "Test with: cd $PROJECT && claude --debug"
echo "Then run /hooks to verify"
