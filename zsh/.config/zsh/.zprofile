# ~/.zprofile - Login Shell Setup
# Runs ONCE when you log in (not for every shell)

# Added by OrbStack: command-line tools and integration
if [[ -f ~/.orbstack/shell/init.zsh ]]; then
  if ! source ~/.orbstack/shell/init.zsh 2>&1; then
    print -P "%F{yellow}WARNING: OrbStack init failed to load%f" >&2
  fi
fi

# Note: Homebrew setup moved to ~/.zshenv for universal availability
