# 01-path.zsh - PATH Management
# Consolidate all PATH modifications in one place

# ══════════════════════════════════════════════════════════════════════
# PATH Additions
# ══════════════════════════════════════════════════════════════════════

# Add paths one by one (order matters - earlier entries have precedence)
path=(
  # vapi
  "$VAPI_INSTALL/bin"
  # uv/local binaries (Python tools via uv/pipx)
  "$HOME/.local/bin"
  # Bun (JavaScript/TypeScript runtime)
  "$HOME/.bun/bin"
  # Windsurf (Claude Code)
  "$HOME/.codeium/windsurf/bin"
  # nvim lazy-rocks
  "$HOME/.local/share/nvim/lazy-rocks/hererocks/bin"
  # Existing PATH
  $path
)

# OpenJDK (add only if installed via Homebrew)
if command -v brew &>/dev/null; then
  local openjdk_path="$(brew --prefix openjdk 2>/dev/null)/bin"
  [[ -d "$openjdk_path" ]] && path=("$openjdk_path" $path) || true
fi

# Export the updated PATH
export PATH

# ══════════════════════════════════════════════════════════════════════
# MANPATH
# ══════════════════════════════════════════════════════════════════════
[[ -n "$VAPI_INSTALL" ]] && export MANPATH="$VAPI_INSTALL/share/man:$MANPATH"
