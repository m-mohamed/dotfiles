# ~/.zprofile - Login Shell Setup
# Runs ONCE when you log in (not for every shell)

if [[ "$OSTYPE" == darwin* ]]; then
  # Added by OrbStack: command-line tools and integration
  if [[ -f ~/.orbstack/shell/init.zsh ]]; then
    if ! source ~/.orbstack/shell/init.zsh 2>&1; then
      print -P "%F{yellow}WARNING: OrbStack init failed to load%f" >&2
    fi
  fi

  # Obsidian CLI
  export PATH="$PATH:/Applications/Obsidian.app/Contents/MacOS"
fi

# Note: Homebrew setup moved to ~/.zshenv for universal availability
