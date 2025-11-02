# 01-path.zsh - PATH Management
# Consolidate all PATH modifications in one place

# ══════════════════════════════════════════════════════════════════════
# PATH Additions
# ══════════════════════════════════════════════════════════════════════

# Add paths one by one (order matters - earlier entries have precedence)
path=(
  # pnpm
  "$PNPM_HOME"
  # vapi
  "$VAPI_INSTALL/bin"
  # OpenJDK
  "/opt/homebrew/opt/openjdk/bin"
  # uv/local binaries
  "$HOME/.local/bin"
  # npm global packages
  "$HOME/.npm-global/bin"
  # Windsurf (Claude Code)
  "$HOME/.codeium/windsurf/bin"
  # nvim lazy-rocks
  "$HOME/.local/share/nvim/lazy-rocks/hererocks/bin"
  # Existing PATH
  $path
)

# Export the updated PATH
export PATH

# ══════════════════════════════════════════════════════════════════════
# MANPATH
# ══════════════════════════════════════════════════════════════════════
export MANPATH="$VAPI_INSTALL/share/man:$MANPATH"
