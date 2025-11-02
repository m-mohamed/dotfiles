# 00-env.zsh - Environment Variables
# Loaded first, sets up environment for other modules

# ══════════════════════════════════════════════════════════════════════
# XDG Directory Creation (Ensure all required dirs exist)
# ══════════════════════════════════════════════════════════════════════
# Create XDG directories if they don't exist (idempotent, safe to run multiple times)
[[ -d "$XDG_CONFIG_HOME" ]] || mkdir -p "$XDG_CONFIG_HOME"
[[ -d "$XDG_DATA_HOME" ]] || mkdir -p "$XDG_DATA_HOME"
[[ -d "$XDG_CACHE_HOME" ]] || mkdir -p "$XDG_CACHE_HOME"
[[ -d "$XDG_STATE_HOME" ]] || mkdir -p "$XDG_STATE_HOME"

# Create ZSH-specific directories
[[ -d "$XDG_CACHE_HOME/zsh" ]] || mkdir -p "$XDG_CACHE_HOME/zsh"
[[ -d "$XDG_STATE_HOME/zsh" ]] || mkdir -p "$XDG_STATE_HOME/zsh"
[[ -d "$XDG_DATA_HOME/zsh" ]] || mkdir -p "$XDG_DATA_HOME/zsh"

# ══════════════════════════════════════════════════════════════════════
# Editor Configuration
# ══════════════════════════════════════════════════════════════════════
export EDITOR=nvim
export VISUAL=nvim

# ══════════════════════════════════════════════════════════════════════
# Tool-Specific Environment Variables
# ══════════════════════════════════════════════════════════════════════
# nvm
export NVM_DIR="$HOME/.nvm"

# pnpm
export PNPM_HOME="$HOME/Library/pnpm"

# vapi
export VAPI_INSTALL="$HOME/.vapi"

# ══════════════════════════════════════════════════════════════════════
# API Keys (sourced from separate secrets file)
# ══════════════════════════════════════════════════════════════════════
# Load API keys from secrets file if it exists
# Copy 00-env-secrets.zsh.example to 00-env-secrets.zsh and add your keys
if [[ -f "${ZDOTDIR:-$HOME/.config/zsh}/modules/00-env-secrets.zsh" ]]; then
  source "${ZDOTDIR:-$HOME/.config/zsh}/modules/00-env-secrets.zsh"
fi
