# 05-tools.zsh - External Tool Integrations
# Initialize external tools (zoxide, starship, fnm/nvm)

# ══════════════════════════════════════════════════════════════════════
# Node Version Manager (fnm or nvm)
# ══════════════════════════════════════════════════════════════════════
if command -v fnm &>/dev/null; then
  # fnm - Fast Node Manager (preferred)
  eval "$(fnm env --use-on-cd)"
elif [[ -d "$HOME/.nvm" ]]; then
  # nvm - Node Version Manager (fallback)
  export NVM_DIR="$HOME/.nvm"
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
fi

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
