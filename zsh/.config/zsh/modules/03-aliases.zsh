# 03-aliases.zsh - Command Aliases
# All command shortcuts and aliases

# ══════════════════════════════════════════════════════════════════════
# System & Navigation
# ══════════════════════════════════════════════════════════════════════
alias c='clear'
alias ip="ipconfig getifaddr en0"  # Get machine's IP address

# ══════════════════════════════════════════════════════════════════════
# Configuration Management
# ══════════════════════════════════════════════════════════════════════
alias zshconfig="nvim $ZDOTDIR/.zshrc"
alias zshsource="source $ZDOTDIR/.zshrc"
alias sshhome="cd ~/.ssh"
alias sshconfig="nvim ~/.ssh/config"
alias gitconfig="nvim ~/.gitconfig"

# ══════════════════════════════════════════════════════════════════════
# Neovim
# ══════════════════════════════════════════════════════════════════════
alias v='nvim'
alias vi='nvim'
alias vim='nvim'
alias vk='NVIM_APPNAME="nvim-kickstart" nvim'  # Using kickstart config
alias avante='nvim -c "lua vim.defer_fn(function()require(\"avante.api\").zen_mode()end, 100)"'

# ══════════════════════════════════════════════════════════════════════
# Git
# ══════════════════════════════════════════════════════════════════════
alias gits="git status"
alias gitd="git diff"
alias gitl="git lg"
alias gita="git add ."
alias gitc="cz commit"

# ══════════════════════════════════════════════════════════════════════
# Development Tools
# ══════════════════════════════════════════════════════════════════════
alias lg='lazygit'
alias ld='lazydocker'
alias cc='claude'  # Claude Code CLI

# ══════════════════════════════════════════════════════════════════════
# Terminal (WezTerm)
# ══════════════════════════════════════════════════════════════════════
# Nuke WezTerm - graceful quit, kill mux server, clean all state
wez-nuke() {
  # If running inside WezTerm, use AppleScript to quit it gracefully
  # This avoids killing our own shell with pkill
  if [[ -n "$WEZTERM_PANE" ]]; then
    echo "Quitting WezTerm via AppleScript..."
    osascript -e 'quit app "WezTerm"'
    sleep 1  # Give it a moment to quit gracefully
  fi

  # Kill any remaining processes (mux server persists after GUI closes)
  echo "Stopping WezTerm mux server..."
  pkill -9 -f "wezterm-mux-server" 2>/dev/null

  echo "Stopping WezTerm GUI..."
  pkill -9 -f "wezterm-gui" 2>/dev/null

  # Clean up ALL state files (sockets, PID, symlinks, logs)
  echo "Cleaning up WezTerm state..."
  rm -rf ~/.local/share/wezterm/sock 2>/dev/null
  rm -rf ~/.local/share/wezterm/gui-sock-* 2>/dev/null
  rm -rf ~/.local/share/wezterm/pid 2>/dev/null
  rm -rf ~/.local/share/wezterm/default-* 2>/dev/null
  rm -rf ~/.local/share/wezterm/wezterm-gui-log-*.txt 2>/dev/null
  rm -rf ~/.local/share/wezterm/wezterm-log-*.txt 2>/dev/null

  echo "Done. WezTerm nuked. Open fresh when ready."
}
alias wez-reset='wez-nuke'

# ══════════════════════════════════════════════════════════════════════
# Mobile (tmux for Termius/SSH access)
# ══════════════════════════════════════════════════════════════════════
# Start or attach to mobile Claude Code session
alias mobile-claude='tmux new-session -A -s claude'
alias mc='mobile-claude'  # Short alias
alias ta='tmux attach -t'  # Attach to named session
alias tl='tmux list-sessions'  # List sessions
alias tn='tmux new -s'  # New named session: tn fantasy
alias tk='tmux kill-session -t'  # Kill session: tk fantasy
alias ts='tmux switch -t'  # Switch session (from inside tmux)
alias td='tmux detach'  # Detach from session (or Ctrl+b d)

# ══════════════════════════════════════════════════════════════════════
# Completion Definitions for Aliases
# ══════════════════════════════════════════════════════════════════════

# Make aliases use their original command's completion
compdef v=nvim
compdef vi=nvim
compdef vim=nvim
compdef vk=nvim
compdef avante=nvim
# Note: lazygit and lazydocker don't provide ZSH completions
# compdef lg=lazygit
# compdef ld=lazydocker

# Git aliases use git completion
compdef gits=git
compdef gitd=git
compdef gitl=git
compdef gita=git
compdef gitc=git
