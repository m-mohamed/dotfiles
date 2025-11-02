# 00-env.zsh - Environment Variables
# Loaded first, sets up environment for other modules

# ══════════════════════════════════════════════════════════════════════
# XDG Directory Verification
# ══════════════════════════════════════════════════════════════════════
# Verify XDG directories exist (created by install.sh)
# If they don't exist, show error and exit gracefully

verify_xdg_dirs() {
  local required_dirs=(
    "$XDG_CONFIG_HOME"
    "$XDG_DATA_HOME"
    "$XDG_CACHE_HOME"
    "$XDG_STATE_HOME"
    "$XDG_CACHE_HOME/zsh"
    "$XDG_STATE_HOME/zsh"
    "$XDG_DATA_HOME/zsh"
  )

  local missing_dirs=()

  for dir in "${required_dirs[@]}"; do
    if [[ ! -d "$dir" ]]; then
      missing_dirs+=("$dir")
    fi
  done

  if [[ ${#missing_dirs[@]} -gt 0 ]]; then
    print -P "%F{red}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━%f" >&2
    print -P "%F{red}ERROR: Required XDG directories are missing%f" >&2
    print -P "%F{red}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━%f" >&2
    print "" >&2
    print -P "%F{yellow}Missing directories:%f" >&2
    for dir in "${missing_dirs[@]}"; do
      print "  - $dir" >&2
    done
    print "" >&2
    print -P "%F{yellow}To fix this, run:%f" >&2
    print "  cd ~/dotfiles && ./install.sh" >&2
    print "" >&2
    return 1
  fi
}

# Run verification
if ! verify_xdg_dirs; then
  # Return early to prevent loading rest of config with broken environment
  return 1
fi

# ══════════════════════════════════════════════════════════════════════
# Editor Configuration
# ══════════════════════════════════════════════════════════════════════
export EDITOR=nvim
export VISUAL=nvim

# ══════════════════════════════════════════════════════════════════════
# Tool-Specific Environment Variables
# ══════════════════════════════════════════════════════════════════════
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
