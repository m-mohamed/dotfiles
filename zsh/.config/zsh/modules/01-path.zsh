# 01-path.zsh - PATH Management
# Consolidate all PATH modifications in one place

# Auto-deduplicate PATH entries
typeset -U path

# ══════════════════════════════════════════════════════════════════════
# PATH Additions
# ══════════════════════════════════════════════════════════════════════

# Add paths one by one (order matters - earlier entries have precedence)
path=(
  # uv/local binaries (Python tools via uv/pipx)
  "$HOME/.local/bin"
  # Bun (JavaScript/TypeScript runtime)
  "$HOME/.bun/bin"
  # pnpm
  "$HOME/.local/share/pnpm"
  # Existing PATH
  $path
)

# Export the updated PATH
export PATH

# pnpm home (used by pnpm itself)
export PNPM_HOME="$HOME/.local/share/pnpm"
