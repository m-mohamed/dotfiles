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

# Git shortcuts (g prefix)
alias g='git'
alias ga='git add'
alias gaa='git add --all'
alias gb='git branch'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gcm='git commit -m'
alias gca='git commit --amend'
alias gp='git push'
alias gpf='git push --force-with-lease'
alias gpl='git pull'
alias gst='git stash'
alias gstp='git stash pop'
alias glo='git log --oneline -20'
alias grb='git rebase'
alias grbi='git rebase -i'
alias grs='git reset'
alias grsh='git reset --hard'
alias gcp='git cherry-pick'

# ══════════════════════════════════════════════════════════════════════
# Development Tools
# ══════════════════════════════════════════════════════════════════════
alias lg='lazygit'
alias ld='lazydocker'
alias cc='claude'  # Claude Code CLI

# ══════════════════════════════════════════════════════════════════════
# Rehoboam (Claude Code Monitoring)
# ══════════════════════════════════════════════════════════════════════
alias rh='rehoboam'               # Start TUI
alias rhd='rehoboam --debug'      # Start with debug log
alias rhi='rehoboam init'         # Init hooks in current project

# ══════════════════════════════════════════════════════════════════════
# Cargo / Rust
# ══════════════════════════════════════════════════════════════════════
alias cr='cargo run'
alias cb='cargo build'
alias ct='cargo test'
alias cw='cargo watch -x run'     # Auto-reload on changes
alias cc!='cargo clippy -- -D warnings'
alias cch='cargo check'

# ══════════════════════════════════════════════════════════════════════
# Tmux (Primary Workflow)
# ══════════════════════════════════════════════════════════════════════
alias tb='tmux-boot'              # Project launcher (interactive)
alias ta='tmux attach -t'         # Attach: ta avaza
alias tl='tmux list-sessions'     # List sessions
alias tn='tmux new -s'            # New: tn myproject
alias tk='tmux kill-session -t'   # Kill: tk myproject
alias ts='tmux switch -t'         # Switch (inside tmux): ts avaza
alias td='tmux detach'            # Detach

# Mobile shortcut (same as any session)
alias mobile-claude='tmux new-session -A -s claude'
alias mc='mobile-claude'

# Tmux window/pane shortcuts
alias tw='tmux list-windows'      # List windows
alias tp='tmux list-panes'        # List panes
alias tka='tmux kill-server'      # Kill all (nuclear)

# Tmux Nuclear Reset (clean slate)
tmux-nuke() {
  echo "Killing all tmux sessions..."
  tmux kill-server 2>/dev/null || true
  rm -f /tmp/rehoboam.sock
  echo "Done. Tmux nuked. Run 'tb' to restart."
}
alias tmux-reset='tmux-nuke'

# ══════════════════════════════════════════════════════════════════════
# Quick Project Navigation
# ══════════════════════════════════════════════════════════════════════
alias dot='cd ~/dotfiles'
alias proj='cd ~/startups'
alias reh='cd ~/startups/rehoboam'
alias spr='cd ~/startups/sprites-rs'
alias ava='cd ~/startups/avaza'
alias slip='cd ~/obsidian/slipbox'

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
compdef g=git
compdef ga=git
compdef gaa=git
compdef gb=git
compdef gco=git
compdef gcb=git
compdef gcm=git
compdef gca=git
compdef gp=git
compdef gpf=git
compdef gpl=git
compdef gst=git
compdef gstp=git
compdef glo=git
compdef grb=git
compdef grbi=git
compdef grs=git
compdef grsh=git
compdef gcp=git
compdef gits=git
compdef gitd=git
compdef gitl=git
compdef gita=git
compdef gitc=git

# Tmux aliases use tmux completion
compdef ta=tmux
compdef tk=tmux
compdef tn=tmux
compdef ts=tmux
