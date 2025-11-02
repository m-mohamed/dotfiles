# 07-modern-tools.zsh - Modern CLI Tool Configurations
# Configure modern Rust-based CLI tools with Tokyo Night theming

# ══════════════════════════════════════════════════════════════════════
# eza - Modern ls replacement
# ══════════════════════════════════════════════════════════════════════
if command -v eza &>/dev/null; then
  alias ls='eza --icons --group-directories-first'
  alias ll='eza -l --icons --group-directories-first --git'
  alias la='eza -la --icons --group-directories-first --git'
  alias tree='eza --tree --icons'
  alias lt='eza --tree --icons --level=2'
fi

# ══════════════════════════════════════════════════════════════════════
# bat - Better cat with syntax highlighting
# ══════════════════════════════════════════════════════════════════════
if command -v bat &>/dev/null; then
  export BAT_THEME="tokyonight_night"
  alias cat='bat --style=plain --paging=never'
  alias catp='bat --style=full'
  alias bathelp='bat --plain --language=help'

  # Use bat for man pages
  export MANPAGER="sh -c 'col -bx | bat -l man -p'"
  export MANROFFOPT="-c"

  # Helper function for --help output
  help() {
    "$@" --help 2>&1 | bathelp
  }
fi

# ══════════════════════════════════════════════════════════════════════
# fzf - Fuzzy finder (Tokyo Night theme)
# ══════════════════════════════════════════════════════════════════════
if command -v fzf &>/dev/null; then
  # Tokyo Night color scheme (exact colors from folke/tokyonight.nvim)
  export FZF_DEFAULT_OPTS="
    --color=fg:#c0caf5,bg:#1a1b26,hl:#bb9af7
    --color=fg+:#c0caf5,bg+:#292e42,hl+:#7dcfff
    --color=info:#7aa2f7,prompt:#7dcfff,pointer:#7dcfff
    --color=marker:#7dcfff,spinner:#7dcfff,header:#7aa2f7
    --border=rounded
    --prompt='❯ '
    --pointer='▶'
    --marker='✓'
    --layout=reverse
    --info=inline
    --height=80%
  "

  # Use fd for file searching (preferred - designed for finding files)
  if command -v fd &>/dev/null; then
    export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_ALT_C_COMMAND='fd --type d --hidden --follow --exclude .git'
  # Fallback to ripgrep if fd not available
  elif command -v rg &>/dev/null; then
    export FZF_DEFAULT_COMMAND='rg --files --hidden --follow --glob "!.git/*"'
  fi

  # Previews with bat and eza
  if command -v bat &>/dev/null && command -v eza &>/dev/null; then
    show_file_or_dir_preview="if [ -d {} ]; then eza --tree --color=always {} | head -200; else bat -n --color=always --line-range :500 {}; fi"
    export FZF_CTRL_T_OPTS="--preview '$show_file_or_dir_preview'"
    export FZF_ALT_C_OPTS="--preview 'eza --tree --color=always {} | head -200'"
  fi

  # Source fzf key bindings and completion
  source <(fzf --zsh) 2>/dev/null
fi

# ══════════════════════════════════════════════════════════════════════
# direnv - Project-specific environment variables
# ══════════════════════════════════════════════════════════════════════
if command -v direnv &>/dev/null; then
  eval "$(direnv hook zsh)"
fi

# ══════════════════════════════════════════════════════════════════════
# delta - Better git diffs
# ══════════════════════════════════════════════════════════════════════
if command -v delta &>/dev/null; then
  export GIT_PAGER='delta'
fi
