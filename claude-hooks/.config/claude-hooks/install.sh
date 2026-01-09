#!/bin/bash
# install.sh - Install Claude hooks and CLAUDE.md snippets to project(s)
# Usage:
#   install.sh <project-path>   # Single project
#   install.sh --all            # All projects from projects.json
#
# Actions:
#   1. Copies project-settings.json to <project>/.claude/settings.json
#   2. Appends claude-md-snippet.md to <project>/CLAUDE.md (idempotent)
#
set -euo pipefail

# Get the directory where this script lives
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECTS_JSON="$SCRIPT_DIR/projects.json"
TEMPLATE="$SCRIPT_DIR/project-settings.json"
CLAUDE_MD_SNIPPET="$SCRIPT_DIR/claude-md-snippet.md"

# Check required files exist
if [[ ! -f "$TEMPLATE" ]]; then
  echo "Error: Template not found: $TEMPLATE"
  exit 1
fi

if [[ ! -f "$PROJECTS_JSON" ]]; then
  echo "Error: Projects config not found: $PROJECTS_JSON"
  exit 1
fi

if [[ ! -f "$CLAUDE_MD_SNIPPET" ]]; then
  echo "Error: CLAUDE.md snippet not found: $CLAUDE_MD_SNIPPET"
  exit 1
fi

# Install hooks to a project
install_hooks() {
  local project="$1"
  local expanded="${project/#\~/$HOME}"

  if [[ ! -d "$expanded" ]]; then
    echo "  Warning: Directory does not exist: $expanded (skipping)"
    return 0
  fi

  # Create .claude directory if it doesn't exist
  mkdir -p "$expanded/.claude"

  # Check if settings.json already exists
  local target="$expanded/.claude/settings.json"
  if [[ -f "$target" ]]; then
    cp "$target" "$target.bak"
    echo "    Backed up settings.json"
  fi

  # Copy template
  cp "$TEMPLATE" "$target"
  echo "    Installed hooks"
}

# Append CLAUDE.md snippet (idempotent)
append_claude_md_snippet() {
  local project="$1"
  local expanded="${project/#\~/$HOME}"
  local claude_md="$expanded/CLAUDE.md"

  # Skip if project doesn't have CLAUDE.md
  if [[ ! -f "$claude_md" ]]; then
    echo "    No CLAUDE.md found (skipping snippet)"
    return 0
  fi

  # Skip if snippet already present (check for marker comment)
  if grep -q "BEGIN SHARED: Modern CLI Tools" "$claude_md" 2>/dev/null; then
    echo "    CLAUDE.md snippet already present"
    return 0
  fi

  # Append snippet
  echo "" >> "$claude_md"
  cat "$CLAUDE_MD_SNIPPET" >> "$claude_md"
  echo "    Added Modern CLI Tools snippet to CLAUDE.md"
}

# Install to a single project
install_to_project() {
  local project="$1"
  install_hooks "$project"
  append_claude_md_snippet "$project"
}

# Handle --all flag
if [[ "${1:-}" == "--all" ]]; then
  echo "Syncing hooks and CLAUDE.md to all projects..."
  echo ""

  # Read projects from JSON
  while IFS= read -r project; do
    name=$(jq -r ".[] | select(.path == \"$project\") | .name" "$PROJECTS_JSON")
    echo "$name ($project):"
    install_to_project "$project"
    echo ""
  done < <(jq -r '.[].path' "$PROJECTS_JSON")

  echo "Done! All projects synced."
  echo ""
  echo "Hooks enabled (12):"
  echo "  SessionStart, UserPromptSubmit, PermissionRequest, Stop, Notification,"
  echo "  PreToolUse, PostToolUse, SessionEnd, PreCompact, PostCompact,"
  echo "  SubagentStart, SubagentStop"
  echo ""
  echo "CLAUDE.md updated with:"
  echo "  Modern CLI Tools section (eza, bat, rg, fd, delta)"
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
  echo "  install.sh --all          # All projects from projects.json"
  echo ""
  echo "Projects configured:"
  jq -r '.[] | "  \(.name): \(.path)"' "$PROJECTS_JSON"
  exit 1
fi

# Expand ~ if present
PROJECT="${PROJECT/#\~/$HOME}"

if [[ ! -d "$PROJECT" ]]; then
  echo "Error: Directory does not exist: $PROJECT"
  exit 1
fi

echo "Installing to $(basename "$PROJECT"):"
install_to_project "$PROJECT"
echo ""
echo "Hooks enabled (12):"
echo "  SessionStart, UserPromptSubmit, PermissionRequest, Stop, Notification,"
echo "  PreToolUse, PostToolUse, SessionEnd, PreCompact, PostCompact,"
echo "  SubagentStart, SubagentStop"
echo ""
echo "Test with: cd $PROJECT && claude /hooks"
