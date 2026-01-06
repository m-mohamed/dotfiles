#!/bin/bash
# install.sh - Install Claude hooks to project(s)
# Usage:
#   install.sh <project-path>   # Single project
#   install.sh --all            # All known projects
#
# Copies project-settings.json to <project>/.claude/settings.json
# This enables Claude Code hooks for that project.

set -euo pipefail

# Known projects for --all flag
PROJECTS=(
  "$HOME/dotfiles"
  "$HOME/startups/avaza"
  "$HOME/startups/avaza-vri"
  "$HOME/startups/ring-chase/fantasy-basketball-agent"
  "$HOME/obsidian/slipbox"
)

# Get the directory where this script lives
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE="$SCRIPT_DIR/project-settings.json"

install_to_project() {
  local project="$1"

  if [[ ! -d "$project" ]]; then
    echo "Warning: Directory does not exist: $project (skipping)"
    return 0
  fi

  # Create .claude directory if it doesn't exist
  mkdir -p "$project/.claude"

  # Check if settings.json already exists
  local target="$project/.claude/settings.json"
  if [[ -f "$target" ]]; then
    echo "  Backing up $target → settings.json.bak"
    cp "$target" "$target.bak"
  fi

  # Copy template
  cp "$TEMPLATE" "$target"
  echo "  Installed hooks to $target"
}

# Check template exists
if [[ ! -f "$TEMPLATE" ]]; then
  echo "Error: Template not found: $TEMPLATE"
  exit 1
fi

# Handle --all flag
if [[ "${1:-}" == "--all" ]]; then
  echo "Syncing hooks to all projects..."
  echo ""
  for project in "${PROJECTS[@]}"; do
    echo "$(basename "$project"):"
    install_to_project "$project"
  done
  echo ""
  echo "Done! All projects synced with 9-hook configuration."
  echo ""
  echo "Hooks enabled:"
  echo "  SessionStart, UserPromptSubmit, PreToolUse, PostToolUse,"
  echo "  PermissionRequest, Notification, Stop, SessionEnd, PreCompact"
  exit 0
fi

# Single project mode
PROJECT="${1:-}"

if [[ -z "$PROJECT" ]]; then
  echo "Usage: install.sh <project-path>"
  echo "       install.sh --all"
  echo ""
  echo "Examples:"
  echo "  install.sh ~/myproject    # Single project"
  echo "  install.sh --all          # All known projects"
  exit 1
fi

# Expand ~ if present
PROJECT="${PROJECT/#\~/$HOME}"

if [[ ! -d "$PROJECT" ]]; then
  echo "Error: Directory does not exist: $PROJECT"
  exit 1
fi

echo "Installing hooks to $(basename "$PROJECT"):"
install_to_project "$PROJECT"
echo ""
echo "Hooks enabled:"
echo "  SessionStart, UserPromptSubmit, PreToolUse, PostToolUse,"
echo "  PermissionRequest, Notification, Stop, SessionEnd, PreCompact"
echo ""
echo "Test with: cd $PROJECT && claude --debug"
echo "Then run /hooks to verify"
