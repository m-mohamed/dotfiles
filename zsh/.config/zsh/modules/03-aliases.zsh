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
alias pn=pnpm

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
compdef pn=pnpm

# Git aliases use git completion
compdef gits=git
compdef gitd=git
compdef gitl=git
compdef gita=git
compdef gitc=git
