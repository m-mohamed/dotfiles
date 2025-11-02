# 02-options.zsh - Zsh Options, History & Completion
# Configure shell behavior, history management, and completion system

# ══════════════════════════════════════════════════════════════════════
# History Configuration
# ══════════════════════════════════════════════════════════════════════
HISTFILE="$XDG_STATE_HOME/zsh/history"
HISTSIZE=50000
SAVEHIST=50000

# Note: History directory created in 00-env.zsh

# History options
setopt EXTENDED_HISTORY          # Write timestamp to history file
setopt HIST_EXPIRE_DUPS_FIRST    # Expire duplicate entries first
setopt HIST_IGNORE_DUPS          # Don't record duplicate entries
setopt HIST_IGNORE_SPACE         # Don't record entries starting with space
setopt HIST_VERIFY               # Show command with history expansion before running
setopt SHARE_HISTORY             # Share history across sessions

# ══════════════════════════════════════════════════════════════════════
# Shell Options
# ══════════════════════════════════════════════════════════════════════
setopt AUTO_CD                   # cd by typing directory name
setopt AUTO_PUSHD                # Make cd push old dir to dirstack
setopt PUSHD_IGNORE_DUPS         # Don't push duplicates
setopt PUSHD_SILENT              # Don't print dirstack after pushd/popd
setopt INTERACTIVE_COMMENTS      # Allow comments in interactive shell
unsetopt BEEP                    # Disable system beep (prevents screen flashing)

# ══════════════════════════════════════════════════════════════════════
# Completion System
# ══════════════════════════════════════════════════════════════════════
autoload -Uz compinit

# Cache completions for better performance (XDG compliant)
# Only regenerate once per day or if missing
compfile="$XDG_CACHE_HOME/zsh/.zcompdump"

# Regenerate if file doesn't exist OR is older than 24 hours
if [[ ! -f "$compfile" || -n ${compfile}(#qN.mh+24) ]]; then
  compinit -d "$compfile"
else
  compinit -C -d "$compfile"  # -C skips security check (faster)
fi

# Modern completion styles
zstyle ':completion:*' menu select                          # Visual menu
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'   # Case insensitive
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"     # Colored completion
zstyle ':completion:*' special-dirs true                    # Complete . and ..
zstyle ':completion:*' use-cache on                         # Enable caching
zstyle ':completion:*' cache-path "$XDG_CACHE_HOME/zsh/zcompcache"

# Note: XDG directories created in 00-env.zsh

# ══════════════════════════════════════════════════════════════════════
# Modern Completion Enhancements
# ══════════════════════════════════════════════════════════════════════

# Completion behavior
zstyle ':completion:*' completer _extensions _complete _approximate
zstyle ':completion:*' complete-options true
zstyle ':completion:*' file-sort modification
zstyle ':completion:*' squeeze-slashes true
zstyle ':completion:*' expand true

# Tokyo Night themed completion appearance
zstyle ':completion:*:*:*:*:descriptions' format '%F{110}-- %d --%f'
zstyle ':completion:*:*:*:*:corrections' format '%F{180}!- %d (errors: %e) -!%f'
zstyle ':completion:*:messages' format '%F{147}-- %d --%f'
zstyle ':completion:*:warnings' format '%F{203}-- no matches found --%f'
zstyle ':completion:*' group-name ''

# Fuzzy matching (progressively less strict)
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

# Better directory completion
zstyle ':completion:*:*:cd:*' tag-order local-directories directory-stack path-directories
zstyle ':completion:*:*:cd:*:directory-stack' menu yes select
zstyle ':completion:*:-tilde-:*' group-order 'named-directories' 'path-directories' 'users' 'expand'
