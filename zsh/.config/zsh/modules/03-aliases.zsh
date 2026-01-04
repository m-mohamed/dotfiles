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
# Reset WezTerm - kills all processes and clears socket/state files
wez-reset() {
  echo "Stopping all WezTerm processes..."
  pkill -f "wezterm" 2>/dev/null || echo "No WezTerm processes running"

  echo "Cleaning up WezTerm socket files..."
  rm -f ~/.local/share/wezterm/sock 2>/dev/null
  rm -f ~/.local/share/wezterm/gui-sock-* 2>/dev/null
  rm -f ~/.local/share/wezterm/pid 2>/dev/null
  rm -f ~/.local/share/wezterm/default-* 2>/dev/null

  echo "Done. Restart WezTerm for a clean slate."
}
alias wez-nuke='wez-reset'

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
