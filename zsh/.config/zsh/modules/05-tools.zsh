# 05-tools.zsh - External Tool Integrations
# Initialize external tools (zoxide, starship)

# ══════════════════════════════════════════════════════════════════════
# zoxide - Smart cd
# ══════════════════════════════════════════════════════════════════════
if command -v zoxide &>/dev/null; then
  eval "$(zoxide init zsh)"
  alias zi='z -i'  # Interactive selection
fi

# ══════════════════════════════════════════════════════════════════════
# Starship Prompt
# ══════════════════════════════════════════════════════════════════════
if command -v starship &>/dev/null; then
  eval "$(starship init zsh)"
fi
