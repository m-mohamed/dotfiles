# 05-tools.zsh - External Tool Integrations
# Initialize external tools (nvm lazy loaded, zoxide)

# ══════════════════════════════════════════════════════════════════════
# nvm - Lazy Loading (Saves ~200ms startup time)
# ══════════════════════════════════════════════════════════════════════
# Create stub functions that load nvm only when needed
if [ -s "/opt/homebrew/opt/nvm/nvm.sh" ]; then
  # Lazy load function
  _load_nvm() {
    unset -f nvm node npm npx
    source "/opt/homebrew/opt/nvm/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && source "$NVM_DIR/bash_completion"
  }

  # Stub functions
  nvm() {
    _load_nvm
    nvm "$@"
  }

  node() {
    _load_nvm
    node "$@"
  }

  npm() {
    _load_nvm
    npm "$@"
  }

  npx() {
    _load_nvm
    npx "$@"
  }
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
