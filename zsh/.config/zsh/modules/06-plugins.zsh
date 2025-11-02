# 06-plugins.zsh - Plugin Management & Configuration
# Loads and configures ZSH plugins via Antidote

# ══════════════════════════════════════════════════════════════════════
# Antidote Plugin Manager
# ══════════════════════════════════════════════════════════════════════

# Path to antidote installation
ANTIDOTE_HOME="${ANTIDOTE_HOME:-${XDG_DATA_HOME:-$HOME/.local/share}/antidote}"

# Clone antidote if not installed (pinned to v1.9.0 for stability)
if [[ ! -d "$ANTIDOTE_HOME" ]]; then
  print -P "%F{cyan}Installing antidote v1.9.0...%f"
  if ! git clone --depth=1 --branch v1.9.0 \
    https://github.com/mattmc3/antidote.git "$ANTIDOTE_HOME" 2>&1; then
    print -P "%F{red}ERROR: Antidote installation failed%f" >&2
    print -P "%F{yellow}Check your internet connection and try again%f" >&2
    print -P "%F{yellow}Or run: cd ~/dotfiles && ./install.sh%f" >&2
    return 1
  fi
  print -P "%F{green}✓ Antidote installed%f"
fi

# Verify antidote.zsh exists
if [[ ! -f "$ANTIDOTE_HOME/antidote.zsh" ]]; then
  print -P "%F{red}ERROR: Antidote not found at $ANTIDOTE_HOME%f" >&2
  print -P "%F{yellow}Run: cd ~/dotfiles && ./install.sh%f" >&2
  return 1
fi

# Static plugin loading with lazy regeneration (2025 best practice)
zsh_plugins=${ZDOTDIR:-$HOME/.config/zsh}/.zsh_plugins

# Regenerate plugin file if needed
if [[ ! ${zsh_plugins}.zsh -nt ${zsh_plugins}.txt ]]; then
  print -P "%F{cyan}Generating plugin bundle...%f"

  # Source antidote with error checking
  if ! source "$ANTIDOTE_HOME/antidote.zsh" 2>&1; then
    print -P "%F{red}ERROR: Failed to source antidote%f" >&2
    return 1
  fi

  # Generate bundle with error checking
  if ! antidote bundle <${zsh_plugins}.txt >${zsh_plugins}.zsh 2>&1; then
    print -P "%F{red}ERROR: Plugin bundle generation failed%f" >&2
    # Remove potentially broken file
    rm -f ${zsh_plugins}.zsh
    return 1
  fi

  # Verify generated file is not empty
  if [[ ! -s ${zsh_plugins}.zsh ]]; then
    print -P "%F{red}ERROR: Generated plugin file is empty%f" >&2
    rm -f ${zsh_plugins}.zsh
    return 1
  fi

  print -P "%F{green}✓ Plugin bundle generated%f"
fi

# Source plugins with verification
if [[ -f ${zsh_plugins}.zsh ]]; then
  source ${zsh_plugins}.zsh
else
  print -P "%F{yellow}WARNING: No plugin file found at ${zsh_plugins}.zsh%f" >&2
  print -P "%F{yellow}Plugins will not be loaded. Run: cd ~/dotfiles && ./install.sh%f" >&2
fi

# ══════════════════════════════════════════════════════════════════════
# Plugin Configurations (Applied After Loading)
# ══════════════════════════════════════════════════════════════════════

# zsh-autosuggestions - Fish-like suggestions
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#565f89'  # Tokyo Night dim color
ZSH_AUTOSUGGEST_STRATEGY=(history completion)
ZSH_AUTOSUGGEST_BUFFER_MAX_SIZE=20
ZSH_AUTOSUGGEST_USE_ASYNC=1

# zsh-syntax-highlighting - Tokyo Night color scheme
typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[unknown-token]='fg=#f7768e'          # Red - errors
ZSH_HIGHLIGHT_STYLES[reserved-word]='fg=#bb9af7'          # Purple - keywords
ZSH_HIGHLIGHT_STYLES[alias]='fg=#7aa2f7'                  # Blue - aliases
ZSH_HIGHLIGHT_STYLES[suffix-alias]='fg=#7aa2f7'           # Blue
ZSH_HIGHLIGHT_STYLES[builtin]='fg=#7aa2f7'                # Blue - builtins
ZSH_HIGHLIGHT_STYLES[function]='fg=#7aa2f7'               # Blue - functions
ZSH_HIGHLIGHT_STYLES[command]='fg=#7aa2f7'                # Blue - commands
ZSH_HIGHLIGHT_STYLES[precommand]='fg=#7aa2f7,italic'      # Blue italic
ZSH_HIGHLIGHT_STYLES[commandseparator]='fg=#bb9af7'       # Purple
ZSH_HIGHLIGHT_STYLES[hashed-command]='fg=#7aa2f7'         # Blue
ZSH_HIGHLIGHT_STYLES[path]='fg=#c0caf5,underline'         # Foreground underlined
ZSH_HIGHLIGHT_STYLES[path_pathseparator]='fg=#565f89'     # Dim
ZSH_HIGHLIGHT_STYLES[path_prefix]='fg=#c0caf5,underline'  # Foreground
ZSH_HIGHLIGHT_STYLES[globbing]='fg=#7dcfff'               # Cyan
ZSH_HIGHLIGHT_STYLES[history-expansion]='fg=#bb9af7'      # Purple
ZSH_HIGHLIGHT_STYLES[single-hyphen-option]='fg=#e0af68'   # Yellow
ZSH_HIGHLIGHT_STYLES[double-hyphen-option]='fg=#e0af68'   # Yellow
ZSH_HIGHLIGHT_STYLES[back-quoted-argument]='fg=#bb9af7'   # Purple
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=#9ece6a' # Green
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=#9ece6a' # Green
ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]='fg=#9ece6a' # Green
ZSH_HIGHLIGHT_STYLES[dollar-double-quoted-argument]='fg=#7dcfff' # Cyan
ZSH_HIGHLIGHT_STYLES[back-double-quoted-argument]='fg=#7dcfff'   # Cyan
ZSH_HIGHLIGHT_STYLES[assign]='fg=#c0caf5'                 # Foreground
ZSH_HIGHLIGHT_STYLES[redirection]='fg=#bb9af7'            # Purple
ZSH_HIGHLIGHT_STYLES[comment]='fg=#565f89,italic'         # Dim italic

# zsh-history-substring-search - Key bindings
if [[ -n "${key[Up]}" ]]; then
  bindkey "${key[Up]}" history-substring-search-up
fi
if [[ -n "${key[Down]}" ]]; then
  bindkey "${key[Down]}" history-substring-search-down
fi
# Vi mode bindings
bindkey -M vicmd 'k' history-substring-search-up
bindkey -M vicmd 'j' history-substring-search-down
