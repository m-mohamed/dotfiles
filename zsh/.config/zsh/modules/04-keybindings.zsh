# 04-keybindings.zsh - Key Bindings & Vi Mode
# Pure vi mode with visual cursor feedback

# ══════════════════════════════════════════════════════════════════════
# Vi Mode Configuration
# ══════════════════════════════════════════════════════════════════════
bindkey -v

# Reduce ESC delay to 10ms for instant mode switching
export KEYTIMEOUT=1

# ══════════════════════════════════════════════════════════════════════
# Cursor Shape Management (Ghostty/Tmux Compatible)
# ══════════════════════════════════════════════════════════════════════

# Change cursor shape based on vi mode
function zle-keymap-select {
  case $KEYMAP in
    vicmd)      echo -ne '\e[1 q' ;;  # Block cursor (command mode)
    viins|main) echo -ne '\e[5 q' ;;  # Beam cursor (insert mode)
  esac
}
zle -N zle-keymap-select

# Initialize with beam cursor (insert mode)
function zle-line-init {
  echo -ne '\e[5 q'
}
zle -N zle-line-init

# Reset cursor on each prompt
function reset-cursor {
  echo -ne '\e[5 q'
}
precmd_functions+=(reset-cursor)

# ══════════════════════════════════════════════════════════════════════
# Vi Mode Key Remappings
# ══════════════════════════════════════════════════════════════════════

# Fast escape with 'jk' in insert mode
bindkey -M viins 'jk' vi-cmd-mode

# ══════════════════════════════════════════════════════════════════════
# Vi Mode History Search
# ══════════════════════════════════════════════════════════════════════

bindkey -M vicmd '/' history-incremental-search-backward
bindkey -M vicmd '?' history-incremental-search-forward
bindkey -M vicmd 'n' history-search-forward
bindkey -M vicmd 'N' history-search-backward

# Incremental search in insert mode (Ctrl+R only - standard vi)
bindkey -M viins '^R' history-incremental-search-backward

# ══════════════════════════════════════════════════════════════════════
# Vim Keys in Completion Menu
# ══════════════════════════════════════════════════════════════════════

zmodload zsh/complist
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect 'j' vi-down-line-or-history
bindkey -M menuselect '^[[Z' reverse-menu-complete  # Shift+Tab
