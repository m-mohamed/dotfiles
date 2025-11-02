# Dotfiles

Personal macOS development environment as code. This guide teaches you the architecture, technology choices, and best practices behind a modern, performant dotfiles setup.

## Table of Contents

- [Introduction & Philosophy](#introduction--philosophy)
- [Design Decisions & Opinions](#design-decisions--opinions)
- [Quick Start](#quick-start)
- [Configuration Architecture](#configuration-architecture)
- [Technology Stack](#technology-stack)
- [Best Practices](#best-practices)
- [Design Deep Dives](#design-deep-dives)
- [Troubleshooting](#troubleshooting)
- [Learning Path](#learning-path)
- [Further Reading](#further-reading)

---

## Introduction & Philosophy

### What This Is

A complete macOS development environment managed as code with GNU Stow. From shell configuration to window management, every tool is version-controlled, reproducible, and optimized for performance.

**Target audience:**
- Developers wanting to understand dotfile management
- Users migrating from Oh-My-Zsh seeking performance
- Anyone interested in modern Unix tooling best practices

### Core Principles

**1. Speed First**
- Shell startup: <100ms (vs 800ms+ with Oh-My-Zsh)
- Static plugin loading, lazy initialization, completion caching
- Every millisecond matters for daily workflow

**2. Standards Over Custom**
- XDG Base Directory Specification (organized configs)
- GNU Stow (standard Unix tool since 1993)
- No custom scripts where standards exist

**3. Consistency as a Feature**
- Tokyo Night theme: terminal → shell → editor → CLI tools
- Same keybindings everywhere (pure vi mode)
- Visual coherence reduces cognitive load

**4. Explicitness Over Magic**
- Numbered modules show exact load order
- Pure vi mode (no hidden Emacs fallbacks)
- Every choice documented with rationale

**5. Unix Philosophy: Modern Edition**
- Do one thing well (each tool specialized)
- Compose tools (eza + fzf + bat)
- Rust rewrites: 10-100x faster than originals

### How to Use This Guide

**Progressive disclosure:**
- **Beginners**: Read Quick Start → Configuration Architecture → Learning Path
- **Intermediate**: Focus on Technology Stack → Best Practices
- **Advanced**: Design Deep Dives → Troubleshooting → Optimization techniques

Code examples reference actual files: `dot-zshenv/.zshenv:17` means line 17 in that file.

---

## Design Decisions & Opinions

**⚠️ This repo makes opinionated choices that may not match your preferences:**

### Pure Vi Mode (No Hybrid)
- **Our choice**: Disable ALL Emacs bindings (no Ctrl+A, Ctrl+E, Ctrl+K, Ctrl+U)
- **Community standard**: Most vi-mode users keep hybrid mode for convenience
- **Why we chose this**: Muscle memory consistency (shell = Vim = everywhere)
- **Trade-off**: Steeper learning curve, week 1-2 can be frustrating

**If you prefer hybrid mode**: Remove the keybinding overrides in `04-keybindings.zsh`

### Minimal Plugin Philosophy (4 Plugins Only)
- **Our choice**: zsh-syntax-highlighting, zsh-autosuggestions, zsh-completions, zsh-history-substring-search
- **Community standard**: 10-20 plugins is more common in "modern minimal" setups
- **Why we chose this**: Maximum performance (<100ms startup), zero bloat
- **Trade-off**: Missing convenient helpers (git aliases, auto-notify, alias-tips)

**If you want more plugins**: Add to `.zsh_plugins.txt` and regenerate

### Module Numbering 00-09 (Custom Pattern)
- **Our choice**: `0[0-9]-*.zsh` pattern restricts to 10 modules maximum
- **Community standard**: Most systems support 00-99 (SysV init, systemd style)
- **Why we chose this**: 10 modules is plenty, prevents loading 10-foo.zsh before 02-bar.zsh
- **Trade-off**: Arbitrary limit that you'll probably never hit

**If you need more modules**: Change pattern to `[0-9][0-9]-*.zsh` for 00-99 range

### No Oh-My-Zsh (Deliberate Performance Choice)
- **Our choice**: Pure Antidote with static loading
- **Community**: OMZ still very popular (large ecosystem, easy setup)
- **Why we chose this**: 800ms → 85ms startup (10x faster)
- **Trade-off**: Must implement git aliases/functions yourself

**These patterns are optimized for MY workflow** but might not match yours. That's OK! The principles (XDG compliance, static loading, performance focus) are solid even if the specific choices differ.

**Want different patterns?** Fork and adapt! The architecture is flexible.

---

## Quick Start

### One-Command Install

```bash
git clone <your-repo-url> ~/dotfiles
cd ~/dotfiles
./install.sh
exec zsh
```

**What you get immediately:**
- ZSH with <100ms startup
- Tokyo Night themed everything
- Modern CLI tools (eza, bat, fzf, ripgrep, fd, delta, zoxide)
- Vi mode with cursor shapes
- Tiling window manager (Aerospace)
- Full Neovim setup (LazyVim)

### What's Inside

- **Shell**: ZSH with Antidote plugin manager
- **Terminal**: WezTerm with JetBrains Mono Nerd Font
- **Editor**: Neovim (LazyVim)
- **Window Manager**: Aerospace (tiling)
- **Status Bar**: Sketchybar
- **Prompt**: Starship
- **Keyboard**: Karabiner (Home Row Mods)
- **Modern CLI**: eza, bat, fzf, ripgrep, fd, delta, zoxide, direnv, tldr

---

## Configuration Architecture

Understanding the architecture is critical to making informed modifications. This section explains *how* the system is structured before diving into *what* tools we chose.

### XDG Base Directory Specification

**The Problem:**
Traditional Unix dotfiles clutter `$HOME`:
```
~/.zshrc
~/.vimrc
~/.gitconfig
~/.config/
~/.cache/
~/.local/
~/.npmrc
~/.docker/
# ... 50+ more files
```

**The Solution: XDG**
[XDG Base Directory Specification](https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html) organizes configs into four categories:

```bash
# File: dot-zshenv/.zshenv:4-8
export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"  # User configs
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}" # User data
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"     # Cached files
export XDG_STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}" # State files
```

**Why this matters:**
- **Backup**: `tar -czf backup.tar.gz ~/.config ~/.local` captures everything
- **Cleanup**: `rm -rf ~/.cache` safely clears caches without destroying config
- **Portability**: Copy `~/.config` to new machine, done
- **Organization**: Clear separation between config, data, cache, state

**Trade-off:** Not all tools support XDG (looking at you, `~/.npmrc`). We accept this.

### Shell Initialization Order

**Critical concept:** Different shell types source different files.

```
┌─────────────────────────────────────────────────┐
│  Login Shell (ssh, Terminal.app first launch)  │
├─────────────────────────────────────────────────┤
│ 1. .zshenv    ← XDG setup, Homebrew PATH        │
│ 2. .zprofile  ← Login-once tasks (OrbStack)     │
│ 3. .zshrc     ← Interactive setup (modules)     │
└─────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────┐
│  Non-Login Interactive (WezTerm domain, `zsh`) │
├─────────────────────────────────────────────────┤
│ 1. .zshenv    ← XDG setup, Homebrew PATH        │
│ 2. .zshrc     ← Interactive setup (modules)     │
└─────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────┐
│  Non-Interactive (scripts, `zsh -c "command"`) │
├─────────────────────────────────────────────────┤
│ 1. .zshenv    ← XDG setup, Homebrew PATH        │
└─────────────────────────────────────────────────┘
```

**What goes where:**

**`.zshenv`** - ALWAYS sourced (all shell types)
```zsh
# File: dot-zshenv/.zshenv
# Critical PATH setup needed everywhere
export XDG_CONFIG_HOME="$HOME/.config"
export ZDOTDIR="$XDG_CONFIG_HOME/zsh"
eval "$(/opt/homebrew/bin/brew shellenv)"  # ← Must be here!
export PATH="$PATH:$HOME/.local/bin"       # uv tooling
```

**`.zprofile`** - Login shells only (once per session)
```zsh
# File: dot-zprofile/.zprofile
# Tasks that run once when you log in
source ~/.orbstack/shell/init.zsh 2>/dev/null || :
```

**`.zshrc`** - Interactive shells (every terminal)
```zsh
# File: zsh/.config/zsh/.zshrc
# Load all numbered modules in order (00-09 only)
for config_file in ${ZDOTDIR:-$HOME/.config/zsh}/modules/0[0-9]-*.zsh(N); do
  source "$config_file"
done
```

**Real-world impact: WezTerm Unix Domains**

We use WezTerm with persistent Unix domains (`connect_automatically = true`). When you reconnect, shells spawn as **non-login interactive** shells.

❌ **WRONG** - Homebrew in `.zprofile`:
```zsh
# .zprofile (login only)
eval "$(/opt/homebrew/bin/brew shellenv)"

# Non-login shells can't find brew!
$ brew --version
zsh: command not found: brew
```

✅ **RIGHT** - Homebrew in `.zshenv`:
```zsh
# .zshenv (ALL shells)
eval "$(/opt/homebrew/bin/brew shellenv)"

# Works everywhere
$ brew --version
Homebrew 4.2.0
```

This was our **first major bug** after setup. Moving Homebrew to `.zshenv` fixed it permanently.

### Module Numbering System

**Philosophy:** Explicit load order prevents subtle bugs.

```
zsh/.config/zsh/modules/
├── 00-env.zsh              # Environment variables (needed by others)
├── 01-path.zsh             # PATH modifications
├── 02-options.zsh          # Shell options, history, completions
├── 03-aliases.zsh          # Command aliases
├── 04-keybindings.zsh      # Vi mode with cursor shapes
├── 05-tools.zsh            # Tool integrations (nvm, zoxide, starship)
├── 06-plugins.zsh          # Antidote plugin manager
└── 07-modern-tools.zsh     # Modern CLI tools (eza, bat, fzf)
```

**Load order matters:**

```zsh
# 02-options.zsh MUST run before 06-plugins.zsh
# Why? Plugins need completion system initialized

# 02-options.zsh:
autoload -Uz compinit
compinit -d "$XDG_CACHE_HOME/zsh/.zcompdump"

# 06-plugins.zsh:
source ${zsh_plugins}.zsh  # ← Needs compinit already done
```

**Why two-digit prefix?**
- `00-09` = single digit when sorted
- Allows 100 modules (00-99) with proper sort
- Visual: immediately see load order

**Pattern-based loading:**
```zsh
# File: zsh/.config/zsh/.zshrc
# 0[0-9] = only 00-09 (prevents 10-foo.zsh loading before 02-bar.zsh)
for config_file in ${ZDOTDIR:-$HOME/.config/zsh}/modules/0[0-9]-*.zsh(N); do
  source "$config_file"
done
```

The `(N)` glob qualifier means "null if no matches" (no error if directory empty).
The `0[0-9]` pattern restricts to 00-09, ensuring proper sort order even with 10+ modules.

### Static vs Dynamic Plugin Loading

**The Evolution:**

**Generation 1: Manual** (prehistoric)
```zsh
source ~/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
source ~/zsh-autosuggestions/zsh-autosuggestions.zsh
# Update manually, pain
```

**Generation 2: Dynamic** (most people)
```zsh
# Every shell startup:
antidote bundle <.zsh_plugins.txt >.zsh_plugins.zsh  # ← 30-50ms
source .zsh_plugins.zsh
```

**Generation 3: Static** (our approach)
```zsh
# File: zsh/.config/zsh/modules/06-plugins.zsh:12-19

zsh_plugins=${ZDOTDIR}/.zsh_plugins

# Only regenerate if .txt is newer than .zsh
if [[ ! ${zsh_plugins}.zsh -nt ${zsh_plugins}.txt ]]; then
  (
    source "$ANTIDOTE_HOME/antidote.zsh"
    antidote bundle <${zsh_plugins}.txt >${zsh_plugins}.zsh
  )
fi

source ${zsh_plugins}.zsh  # ← Just source, no regeneration
```

**Performance:**
- **Dynamic**: 30-50ms per shell (regenerates every time)
- **Static**: 2-3ms per shell (just sources pre-compiled file)
- Regeneration: Only when you edit `.zsh_plugins.txt`

**How `-nt` works:**
```bash
[[ file1 -nt file2 ]]  # True if file1 newer than file2

# If .zsh doesn't exist OR .txt is newer → regenerate
# Otherwise → skip regeneration
```

### Completion System Optimization

**The Problem:**
`compinit` scans `/usr/share/zsh/site-functions/*` every shell startup. Thousands of files = slow.

**Our Solution:**
```zsh
# File: zsh/.config/zsh/modules/02-options.zsh:37-46

# Completion cache path (XDG compliant)
compfile="$XDG_CACHE_HOME/zsh/.zcompdump"

# Regenerate if file doesn't exist OR is older than 24 hours
if [[ ! -f "$compfile" || -n ${compfile}(#qN.mh+24) ]]; then
  compinit -d "$compfile"
else
  compinit -C -d "$compfile"  # -C = skip security check (faster)
fi
```

**Breakdown:**
- `-f "$compfile"` = check if file exists
- `${compfile}(#qN.mh+24)` = glob qualifier
  - `#q` = enable glob qualifiers
  - `N` = null if no match (returns empty, not error)
  - `.mh+24` = modified more than 24 hours ago
- Logic: If file doesn't exist OR is older than 24h → rebuild
- Otherwise → use cached version (fast)

**Performance:**
- **First run**: 15-20ms (builds cache)
- **Subsequent**: 2-3ms (uses cache with -C flag)
- **Refresh**: Once per day automatically

### Performance Optimization Results

**Our measurements** (2025 M3 Mac):
```bash
$ time zsh -i -c exit
zsh -i -c exit  0.06s user 0.03s system 95% cpu 0.085 total
```

**Breakdown with zprof:**
```
num  calls                time                       self            name
-----------------------------------------------------------------------------------
 1)    1          22.14    22.14   26.05%     22.14    22.14   26.05%  _antidote_load_compat
 2)    1          18.23    18.23   21.45%     18.23    18.23   21.45%  compinit
 3)   12          12.81     1.07   15.08%     12.81     1.07   15.08%  antidote-bundle
 4)    1          10.34    10.34   12.17%     10.34    10.34   12.17%  starship_precmd
 5)    2           8.12     4.06    9.56%      8.12     4.06    9.56%  add-zsh-hook
```

**Total: 85ms** ✅ (target <100ms)

**How we achieved this:**

1. **Static plugin loading** - No bundle regeneration (saved 30ms)
2. **Completion caching** - Once per day (saved 15ms)
3. **Lazy loading** - NVM deferred until first use (saved 200ms)
4. **No Oh-My-Zsh** - Removed 50+ unnecessary plugins (saved 600ms)

**Lazy loading example:**
```zsh
# File: zsh/.config/zsh/modules/05-tools.zsh:8-18

# Load NVM only when needed (not at startup)
export NVM_DIR="$HOME/.nvm"

nvm() {
  unset -f nvm  # Remove this placeholder function
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # Load actual NVM
  nvm "$@"  # Call real nvm with original arguments
}
```

**Trade-off:** First `nvm` call takes 200ms. We accept this because most shells never call `nvm`.

---

## Technology Stack

Now that you understand the architecture, here's *what* we chose and *why*.

### Core Philosophy

Every tool choice optimized for:
1. **Speed** - Rust > Python > Ruby > Shell
2. **Standards** - Established tools > new frameworks
3. **Composability** - Unix pipes, not monoliths
4. **Simplicity** - 4 plugins, not 200

### Dotfile Management: GNU Stow

**What it does:** Creates symlinks from `~/dotfiles/` to `$HOME`.

```
~/dotfiles/zsh/.config/zsh/.zshrc  →  ~/.config/zsh/.zshrc
~/dotfiles/nvim/.config/nvim/      →  ~/.config/nvim/
```

**Alternatives considered:**

| Tool | Pros | Cons | Why Not |
|------|------|------|---------|
| **Bare Git** | Simple, no deps | Manual symlinks, cluttered | Requires scripts |
| **Chezmoi** | Templating, secrets | Complex, Go dependency | Overkill for our needs |
| **yadm** | Git-based, encryption | Magic, less explicit | Prefer explicitness |
| **rcm** | Thoughtbot-made | Ruby dependency | Stow simpler |
| **Custom scripts** | Total control | Reinventing wheel | Stow is standard |

**Why Stow wins:**
- Standard Unix tool (1993, actively maintained)
- Zero configuration (`stow zsh` just works)
- Easy to understand (just symlinks)
- No dependencies beyond Perl (built into macOS)
- Undo is trivial (`stow -D zsh`)

**How it works:**
```bash
# Structure in dotfiles repo
dotfiles/
├── zsh/
│   └── .config/
│       └── zsh/
│           └── .zshrc
└── nvim/
    └── .config/
        └── nvim/
            └── init.lua

# After `stow zsh nvim`
~/.config/zsh/.zshrc → ~/dotfiles/zsh/.config/zsh/.zshrc
~/.config/nvim/init.lua → ~/dotfiles/nvim/.config/nvim/init.lua
```

**Package organization:**
```bash
# Granular packages (per tool)
stow zsh nvim git tmux

# Coarse packages (by category)
stow shell-tools editor-configs

# We choose: Granular (easier to enable/disable individual tools)
```

**Trade-off:** Can't template files like Chezmoi. Solution: Use environment variables or separate secret files.

### Shell & Plugin System

**ZSH vs Bash vs Fish**

| Feature | ZSH | Bash | Fish |
|---------|-----|------|------|
| Speed | Fast | Faster | Fast |
| Plugins | Many | Few | Some |
| Vi mode | Excellent | Basic | Good |
| Completion | Best | Basic | Good |
| POSIX | Compatible | Standard | Incompatible |
| Customization | Infinite | Limited | Opinionated |

**Why ZSH:**
- Best completion system (context-aware, fuzzy, menu)
- Mature plugin ecosystem (zsh-users/*)
- Excellent vi mode with visual feedback
- POSIX compatible (scripts work)
- Industry standard for power users

**Antidote vs Oh-My-Zsh vs Zinit vs Sheldon**

**Oh-My-Zsh:**
```zsh
# ~/.zshrc with Oh-My-Zsh
plugins=(git npm docker aws ... 200+ plugins)
source $ZSH/oh-my-zsh.sh

$ time zsh -i -c exit
0.85s  # ← 850ms startup 😱
```

**Antidote:**
```zsh
# .zsh_plugins.txt
zsh-users/zsh-syntax-highlighting
zsh-users/zsh-autosuggestions
zsh-users/zsh-completions kind:fpath
zsh-users/zsh-history-substring-search

$ time zsh -i -c exit
0.085s  # ← 85ms startup ✅
```

**Performance comparison:**
- Oh-My-Zsh: 800-1000ms (50+ plugins auto-loaded)
- Zinit: 100-200ms (complex, turbo mode tricky)
- Antidote: 80-100ms (static loading)
- Manual: 50-80ms (no manager, just source)

**Why Antidote:**
- **10x faster than OMZ** (800ms → 80ms)
- Simple mental model (just bundles plugins)
- Static loading support (our secret sauce)
- No complex DSL (looking at you, Zinit)
- Active development (mattmc3 maintains)

**Plugin selection philosophy:**

❌ **Don't do this:**
```zsh
# Oh-My-Zsh approach
plugins=(
  git gitignore github
  npm yarn node nvm
  docker docker-compose
  aws gcloud
  ... 50 more
)
# Most you never use, all slow startup
```

✅ **Do this instead:**
```zsh
# File: zsh/.config/zsh/.zsh_plugins.txt

# Only essential plugins
zsh-users/zsh-syntax-highlighting       # Color-code commands
zsh-users/zsh-autosuggestions           # Fish-like suggestions
zsh-users/zsh-completions kind:fpath    # Extra completions
zsh-users/zsh-history-substring-search  # Better history search
```

**Why ONLY these 4:**
- **Syntax highlighting** - Immediate feedback (typo = red)
- **Autosuggestions** - Type faster (history recall)
- **Completions** - More tools supported
- **History search** - Better than Ctrl+R alone

Everything else (git aliases, docker helpers, etc.) we implement as simple aliases or functions in our modules.

**Load order matters:**
```zsh
# WRONG ORDER:
zsh-users/zsh-autosuggestions           # ← Loads first
zsh-users/zsh-syntax-highlighting       # ← Overwrites bindings

# RIGHT ORDER:
zsh-users/zsh-syntax-highlighting       # ← Must load first
zsh-users/zsh-autosuggestions           # ← Then suggestions
```

Syntax highlighting hooks into ZLE (ZSH Line Editor) first, then autosuggestions layer on top.

**Tokyo Night colors for plugins:**
```zsh
# File: zsh/.config/zsh/modules/06-plugins.zsh:23-48

typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[command]='fg=#7aa2f7'                    # Blue
ZSH_HIGHLIGHT_STYLES[alias]='fg=#7aa2f7'                       # Blue
ZSH_HIGHLIGHT_STYLES[builtin]='fg=#7aa2f7'                     # Blue
ZSH_HIGHLIGHT_STYLES[function]='fg=#7dcfff'                    # Cyan
ZSH_HIGHLIGHT_STYLES[command-substitution-delimiter]='fg=#f7768e'  # Red
ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=#9ece6a'      # Green
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=#9ece6a'      # Green
# ... 20+ more styles

# Autosuggestions color
ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#565f89'  # Comment gray
```

Exact hex codes from [folke/tokyonight.nvim](https://github.com/folke/tokyonight.nvim).

### Modern CLI Tools

**The Rust Revolution:**

Traditional Unix tools (1970s-1990s) written in C. Modern rewrites in Rust: memory-safe, parallel, 10-100x faster.

**Tool comparison matrix:**

| Category | Traditional | Modern (Rust) | Speed Gain | Why Modern |
|----------|-------------|---------------|------------|------------|
| **ls** | `ls` | `eza` | 5-10x | Colors, git status, tree |
| **cat** | `cat` | `bat` | 2-3x | Syntax highlighting, paging |
| **find** | `find` | `fd` | 10-50x | Parallel, smart defaults |
| **grep** | `grep` | `ripgrep` | 10-100x | Parallel, respects .gitignore |
| **sed** | `sed` | `sd` | 5-10x | Safer syntax, Unicode |
| **diff** | `diff` | `delta` | N/A | Syntax highlighting, side-by-side |
| **cd** | `cd` | `zoxide` | N/A | Frecency (frequency + recency) |

**Integration story:**

Tools compose beautifully:
```bash
# Find TypeScript files, search for pattern, preview with bat
fd -e ts | fzf --preview 'bat --color=always {}' | xargs rg 'useState'

# Change to recent project, list files with tree
z dotfiles && eza --tree --level=2

# Git diff with syntax highlighting
git diff | delta
```

**Configuration with Tokyo Night:**

**eza:**
```zsh
# File: zsh/.config/zsh/modules/07-modern-tools.zsh:6-13
alias ls='eza --group-directories-first --icons'
alias ll='eza -lh --group-directories-first --icons --git'
alias la='eza -lah --group-directories-first --icons --git'
alias tree='eza --tree --icons'

# Tokyo Night colors via LS_COLORS (set by dircolors or vivid)
export LS_COLORS="di=1;34:ln=1;36:so=1;35:pi=1;33..."
```

**bat:**
```zsh
# File: zsh/.config/zsh/modules/07-modern-tools.zsh:16-21
export BAT_THEME="tokyonight_night"
export BAT_STYLE="numbers,changes,header"
alias cat='bat --paging=never'
alias less='bat'

# Install Tokyo Night theme (done by install.sh)
# bat cache --build
```

**fzf:**
```zsh
# File: zsh/.config/zsh/modules/07-modern-tools.zsh:24-45
export FZF_DEFAULT_OPTS="
  --color=fg:#c0caf5,bg:#1a1b26,hl:#bb9af7
  --color=fg+:#c0caf5,bg+:#292e42,hl+:#7dcfff
  --color=info:#7aa2f7,prompt:#7dcfff,pointer:#7dcfff
  --color=marker:#9ece6a,spinner:#9ece6a,header:#9ece6a
  --border=rounded
  --prompt='❯ '
  --pointer='▶'
  --marker='✓'
  --layout=reverse
  --height=80%
"

# Use fd for file search (respects .gitignore)
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

# Key bindings
source "$(brew --prefix)/opt/fzf/shell/key-bindings.zsh"
```

**delta:**
```gitconfig
# File: dot-gitconfig/.gitconfig:18-28
[core]
    pager = delta

[delta]
    navigate = true
    side-by-side = true
    line-numbers = true
    syntax-theme = "tokyonight_night"

[interactive]
    diffFilter = delta --color-only
```

**Why each tool:**

- **eza**: Git status inline, tree view, icons (better ls)
- **bat**: Syntax highlighting for 200+ languages (better cat)
- **fd**: 50x faster than find, ignores .git automatically
- **ripgrep**: 100x faster than grep, respects .gitignore
- **delta**: Makes git diffs readable (syntax + side-by-side)
- **zoxide**: `z proj` jumps to ~/projects/my-project (smart cd)
- **fzf**: Fuzzy search everything (files, history, processes)

**Trade-off:** Muscle memory adjustment (eza options differ from ls). We accept this for massive UX improvement.

### Terminal & Desktop Environment

**WezTerm: The Terminal**

**vs iTerm2:**
- iTerm2: Feature-rich, macOS-native, mature
- WezTerm: GPU-accelerated, Lua config, cross-platform

**vs Alacritty:**
- Alacritty: Minimal, fastest, YAML config
- WezTerm: More features, better multiplexing

**vs Kitty:**
- Kitty: Fast, image protocol, Python extensions
- WezTerm: Better tab/pane management, Unix domains

**Why WezTerm:**
- **Unix domains** - Persistent sessions without tmux
- **Lua configuration** - Programmable, type-checked
- **GPU rendering** - Smooth scrolling, 60fps
- **Built-in multiplexing** - No tmux needed
- **Cross-platform** - Same config on macOS/Linux

**Unix domains explained:**

Traditional:
```
Terminal → new shell → lost when terminal closes
tmux → persistent session → complex config
```

WezTerm domains:
```
Terminal → connects to domain → persistent
Close terminal → domain stays alive
Reopen terminal → auto-reconnects → same session
```

**Configuration:**
```lua
-- File: wezterm/.config/wezterm/wezterm.lua
config.unix_domains = {
  { name = 'unix' },
}
config.default_gui_startup_args = { 'connect', 'unix' }
config.connect_automatically = true
```

**This is why we needed Homebrew in `.zshenv`!** Domains create non-login shells.

**Aerospace: The Window Manager**

**vs yabai:**
- yabai: Powerful, requires SIP disable
- Aerospace: No SIP disable needed

**vs Amethyst:**
- Amethyst: Auto-tiling (implicit)
- Aerospace: Modal tiling (explicit)

**vs Rectangle:**
- Rectangle: Keyboard shortcuts only
- Aerospace: Full tiling WM

**Why Aerospace:**
- **No SIP disable** - System Integrity Protection stays enabled
- **Modal keybindings** - i3/sway-inspired (muscle memory)
- **Explicit layout** - You control, not AI
- **Stable** - nikitabobko maintains actively

**Karabiner: Home Row Mods**

**What are Home Row Mods?**

Traditional keyboard:
```
Pinky stretches to Cmd/Ctrl/Opt/Shift
↓
RSI, fatigue, slow
```

Home Row Mods:
```
a = A when tapped, Cmd when held
s = S when tapped, Opt when held
d = D when tapped, Ctrl when held
f = F when tapped, Shift when held
```

**Why this matters:**
- No pinky stretching (ergonomic)
- Faster (home row → modifier)
- Works everywhere (system-level)

**Configuration:**
```json
// File: karabiner/.config/karabiner/karabiner.json
{
  "from": { "key_code": "a" },
  "to": [ { "key_code": "a" } ],
  "to_if_held_down": [ { "key_code": "left_command" } ],
  "parameters": {
    "basic.to_if_held_down_threshold_milliseconds": 150
  }
}
```

**Timing is critical:**
- Too short (50ms): Accidental modifiers when typing
- Too long (300ms): Feels laggy
- **Sweet spot: 150ms** (tap vs hold threshold)

**Learning curve:**
- Week 1-2: Frustrating (accidental triggers)
- Week 3-4: Muscle memory forming
- Month 2+: Can't live without it

**Trade-off:** Typing "sass" quickly can trigger modifiers. Solution: Slow down slightly on double letters.

---

## Best Practices

### Secrets Management

**The Problem:**
API keys in dotfiles → commit to Git → exposed on GitHub → compromised.

**The Template Pattern:**

```bash
# File: zsh/.config/zsh/modules/00-env-secrets.zsh.example
export OPENAI_API_KEY="sk-..."
export ANTHROPIC_API_KEY="sk-ant-..."
export DEEPSEEK_API_KEY="..."
```

**Usage:**
```bash
# 1. Copy template
cp 00-env-secrets.zsh.example 00-env-secrets.zsh

# 2. Edit with real keys
nvim 00-env-secrets.zsh

# 3. File is gitignored
# .gitignore contains: **/*-secrets.zsh
```

**Why this works:**
- Template provides documentation (what keys needed)
- Real file never committed (pattern-based gitignore)
- Easy to regenerate (just copy template)
- No external tools needed

**Alternatives considered:**

| Approach | Pros | Cons | Why Not |
|----------|------|------|---------|
| **direnv** | Per-directory | Extra tool, `.envrc` clutter | Prefer simplicity |
| **git-crypt** | Encrypted in repo | Complex, GPG setup | Overkill |
| **1Password CLI** | Secure vault | Requires 1Password | External dependency |
| **ENV vars only** | No files | Lost on reboot, hard to manage | Poor UX |

**Trade-off:** Must manually copy template on new machines. We accept this for simplicity.

**Gitignore strategy:**
```gitignore
# File: .gitignore

# Secrets (pattern-based)
**/*-secrets.zsh
**/.env
**/.env.local

# Generated files
**/.zcompdump*
**/.zsh_plugins.zsh
**/.zsh_history

# Runtime state
**/.DS_Store
**/node_modules

# User-specific
**/.idea
**/.vscode
```

### Reproducibility

**Goal:** Fresh macOS → `./install.sh` → Done in 10 minutes.

**Brewfile: Declarative Dependencies**

```ruby
# File: Brewfile

tap "homebrew/bundle"
tap "FelixKratz/formulae"
tap "nikitabobko/tap"

# Core Shell & Terminal
brew "stow"
brew "zsh"
brew "starship"
cask "wezterm"

# Modern CLI Tools
brew "eza"
brew "bat"
brew "fzf"
brew "ripgrep"
brew "fd"
brew "delta"
brew "zoxide"

# Development
brew "git"
brew "gh"
brew "neovim"
brew "lazygit"

# ... 33 packages total
```

**Install script orchestration:**

```bash
# File: install.sh

#!/usr/bin/env bash

# 1. Check/install Homebrew
if ! command -v brew &> /dev/null; then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# 2. Install dependencies
brew bundle install --no-lock

# 3. Create XDG directories
mkdir -p ~/.config ~/.local/share ~/.cache ~/.local/state

# 4. Backup existing configs
[ -f ~/.zshrc ] && mv ~/.zshrc ~/.zshrc.backup

# 5. Stow packages
stow aerospace borders dot-gitconfig dot-zprofile dot-zshenv \
     gh git karabiner nvim sketchybar ssh starship wezterm zsh

# 6. Install bat Tokyo Night theme
mkdir -p "$(bat --config-dir)/themes"
wget -P "$(bat --config-dir)/themes" \
  https://github.com/folke/tokyonight.nvim/raw/main/extras/sublime/tokyonight_night.tmTheme
bat cache --build

# 7. Copy secrets template
cp zsh/.config/zsh/modules/00-env-secrets.zsh.example \
   zsh/.config/zsh/modules/00-env-secrets.zsh

echo "✅ Dotfiles installed! Run: exec zsh"
```

**Why this is reproducible:**
- No manual steps (fully automated)
- Idempotent (run multiple times safely)
- Self-documenting (Brewfile lists everything)
- Version-controlled (commit Brewfile.lock for exact versions)

**Testing reproducibility:**
```bash
# VM test (OrbStack)
orb create macos:sonoma test-dotfiles
orb shell test-dotfiles
git clone https://github.com/user/dotfiles ~/dotfiles
cd ~/dotfiles && ./install.sh
exec zsh
# Should work perfectly
```

### Maintenance Workflow

**Weekly update ritual:**

```bash
# 1. Update Homebrew packages
brew update && brew upgrade && brew cleanup

# 2. Update Antidote plugins
antidote update

# 3. Clear completion cache (force rebuild)
rm ~/.cache/zsh/.zcompdump && exec zsh

# 4. Test performance
time zsh -i -c exit  # Should still be <100ms

# 5. Commit Brewfile.lock
cd ~/dotfiles
git add Brewfile.lock
git commit -m "chore: update dependencies"
```

**Before making changes:**
```bash
# Test in subshell first
zsh  # ← Subshell, can exit to revert

# Edit config
nvim ~/.config/zsh/modules/03-aliases.zsh

# Test immediately
source ~/.config/zsh/modules/03-aliases.zsh

# If good, commit
cd ~/dotfiles && git add . && git commit -m "feat: add new alias"
```

**Rollback strategy:**
```bash
# Oh no, shell broken!
# Git is your safety net

cd ~/dotfiles
git log --oneline  # Find good commit
git revert HEAD    # Undo last commit
stow -R zsh        # Re-stow
exec zsh           # Fixed!
```

### Common Mistakes

❌ **DON'T: Put Homebrew in `.zprofile`**
```zsh
# .zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"
# ← Breaks WezTerm domains (non-login shells)
```

✅ **DO: Put Homebrew in `.zshenv`**
```zsh
# .zshenv
eval "$(/opt/homebrew/bin/brew shellenv)"
# ← Works everywhere
```

---

❌ **DON'T: Load plugins dynamically**
```zsh
antidote bundle <.zsh_plugins.txt >.zsh_plugins.zsh  # Every shell
source .zsh_plugins.zsh
# ← Adds 30-50ms per shell
```

✅ **DO: Use static loading**
```zsh
if [[ ! ${zsh_plugins}.zsh -nt ${zsh_plugins}.txt ]]; then
  # Regenerate only if .txt changed
fi
source ${zsh_plugins}.zsh  # Just source
```

---

❌ **DON'T: Load everything at startup**
```zsh
source "$NVM_DIR/nvm.sh"  # ← Adds 200ms
source ~/.fzf.zsh
eval "$(direnv hook zsh)"
# Startup: 500ms+
```

✅ **DO: Lazy load heavy tools**
```zsh
nvm() {
  unset -f nvm
  source "$NVM_DIR/nvm.sh"
  nvm "$@"
}
# First nvm call: 200ms
# Shell startup: fast
```

---

❌ **DON'T: Use 200+ plugins**
```zsh
plugins=(git npm docker aws gcloud ... 200 more)
# ← Oh-My-Zsh approach, 800ms startup
```

✅ **DO: Use 4 essential plugins**
```zsh
zsh-users/zsh-syntax-highlighting
zsh-users/zsh-autosuggestions
zsh-users/zsh-completions
zsh-users/zsh-history-substring-search
# ← 85ms startup
```

---

❌ **DON'T: Commit secrets**
```bash
git add .
git commit -m "Add API keys"  # ← Keys now public!
```

✅ **DO: Use template pattern**
```bash
# .gitignore
**/*-secrets.zsh

# Template committed, real file ignored
```

---

## Design Deep Dives

### Pure Vi Mode

**What "pure" means:**

Hybrid vi mode (most setups):
```zsh
bindkey -v  # Enable vi mode
# But Ctrl+A/E/K/U still work (Emacs shortcuts)
```

Pure vi mode (our setup):
```zsh
# File: zsh/.config/zsh/modules/04-keybindings.zsh

bindkey -v
export KEYTIMEOUT=1  # Fast escape (10ms)

# NO Emacs shortcuts
# Ctrl+A = beginning of line? Nope, vi "yank" instead
# Ctrl+E = end of line? Nope, doesn't work
# Use vi motions: 0, $, ^, A, I
```

**Why pure?**

**Muscle memory consistency:**
- Shell: `0` = line start, `$` = line end
- Vim: `0` = line start, `$` = line end
- Everywhere: Same keybindings

**No context switching:**
- No "which mode am I in?" confusion
- No "does Ctrl+A work here?" guessing
- One mental model: vi everywhere

**Visual feedback with cursor shapes:**

```zsh
# File: zsh/.config/zsh/modules/04-keybindings.zsh:7-14

function zle-keymap-select {
  case $KEYMAP in
    vicmd)      echo -ne '\e[1 q' ;;  # █ Block (command mode)
    viins|main) echo -ne '\e[5 q' ;;  # | Beam (insert mode)
  esac
}
zle -N zle-keymap-select

# Also set beam cursor on new prompt
function zle-line-init {
  echo -ne '\e[5 q'  # | Beam (start in insert)
}
zle -N zle-line-init
```

**WezTerm must support DECSCUSR:**
```lua
-- File: wezterm/.config/wezterm/wezterm.lua
config.cursor_blink_rate = 0  # Solid cursor (no blink)
-- DECSCUSR sequences (\e[1 q, \e[5 q) work automatically
```

**Fast escape with `jk`:**

```zsh
# File: zsh/.config/zsh/modules/04-keybindings.zsh:16-17

bindkey -M viins 'jk' vi-cmd-mode  # jk = Esc
export KEYTIMEOUT=1  # 10ms timeout (fast!)
```

**Why `jk` not `jj`?**
- `jj` conflicts with typing "fjjord" or coding "jjwt"
- `jk` rarely appears in English or code
- Same as Vim muscle memory (many use `jk`)

**Vi motions in completion menu:**

```zsh
# File: zsh/.config/zsh/modules/04-keybindings.zsh:36-41

zmodload zsh/complist
bindkey -M menuselect 'h' vi-backward-char      # h = left
bindkey -M menuselect 'j' vi-down-line-or-history   # j = down
bindkey -M menuselect 'k' vi-up-line-or-history     # k = up
bindkey -M menuselect 'l' vi-forward-char       # l = right
```

**Common editing patterns:**

```bash
# Wrong command
$ gti status
  ^^^ cursor here

# Fix: F g r git (Emacs: Ctrl+A, delete, retype)
# Vi: F g (back to g), r (replace), type 'git'
# Result: git status

# Delete word
$ rm important-file.txt
           ^^^^^^^ delete this

# Emacs: Ctrl+W (but from where?)
# Vi: B (back word), dw (delete word)

# Change inside quotes
$ echo "wrong text here"
        ^^^^^^^^^^^^^^^ change this

# Emacs: Manual selection
# Vi: ci" (change inside quotes), type new text
```

**Trade-off:** Learning curve. Week 1-2 frustrating if coming from Emacs. Month 1+, you're faster.

### Tokyo Night Consistency

**Philosophy:** Color as a system, not decoration.

**Source of truth:** [folke/tokyonight.nvim](https://github.com/folke/tokyonight.nvim)

**Color palette (Night variant):**
```
Background: #1a1b26
Foreground: #c0caf5
Black:      #15161e
Red:        #f7768e
Green:      #9ece6a
Yellow:     #e0af68
Blue:       #7aa2f7
Magenta:    #bb9af7
Cyan:       #7dcfff
White:      #a9b1d6
Comment:    #565f89
```

**Where we use exact hex codes:**

**1. ZSH Syntax Highlighting**
```zsh
# File: zsh/.config/zsh/modules/06-plugins.zsh:23-48
typeset -A ZSH_HIGHLIGHT_STYLES
ZSH_HIGHLIGHT_STYLES[command]='fg=#7aa2f7'  # Blue (exact match)
ZSH_HIGHLIGHT_STYLES[string]='fg=#9ece6a'   # Green (exact match)
```

**2. fzf**
```zsh
# File: zsh/.config/zsh/modules/07-modern-tools.zsh:24-35
export FZF_DEFAULT_OPTS="
  --color=fg:#c0caf5,bg:#1a1b26,hl:#bb9af7
  --color=fg+:#c0caf5,bg+:#292e42,hl+:#7dcfff
  --color=info:#7aa2f7,prompt:#7dcfff,pointer:#7dcfff
"
```

**3. bat**
```bash
# File: install.sh:42-44
wget https://github.com/folke/tokyonight.nvim/raw/main/extras/sublime/tokyonight_night.tmTheme
bat cache --build
```

**4. delta (git diff)**
```gitconfig
# File: dot-gitconfig/.gitconfig:25
[delta]
    syntax-theme = "tokyonight_night"
```

**5. Neovim**
```lua
-- File: nvim/.config/nvim/lua/plugins/colorscheme.lua
return {
  "folke/tokyonight.nvim",
  opts = { style = "night" }
}
```

**6. WezTerm**
```lua
-- File: wezterm/.config/wezterm/wezterm.lua
config.color_scheme = "tokyonight_night"
```

**7. Starship**
```toml
# File: starship/.config/starship.toml
# Colors inherited from terminal
# Uses Tokyo Night automatically
```

**Why this matters:**

**Visual coherence:**
- Same blue (#7aa2f7) for commands in shell and Neovim
- Same green (#9ece6a) for strings everywhere
- Same background (#1a1b26) in terminal and editor

**Reduced cognitive load:**
- No context switching (different colors = different tools)
- Instant recognition (blue = command, always)
- Aesthetic calm (harmonious palette)

**Debugging easier:**
- Consistent syntax highlighting
- Same colors in diffs, code, shell

**Trade-off:** Changing themes requires updating 7+ files. We accept this for consistency.

### Home Row Mods Deep Dive

**The Ergonomic Problem:**

Traditional keyboard layout:
```
1  2  3  4  5  6  7  8  9  0
 Q  W  E  R  T  Y  U  I  O  P
  A  S  D  F  G  H  J  K  L  ;
   Z  X  C  V  B  N  M  ,  .  /

Modifiers:  Caps  Ctrl  Opt  Cmd  Space
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^
            Pinky stretch, RSI risk
```

**Frequency analysis:**
- 90% typing: home row (ASDF JKL;)
- 10% modifiers: Cmd, Opt, Ctrl, Shift
- Problem: 10% requires leaving home row → slow, painful

**Home Row Mods Solution:**

```
Left hand:
a = Cmd when held, A when tapped
s = Opt when held, S when tapped
d = Ctrl when held, D when tapped
f = Shift when held, F when tapped

Right hand:
j = Shift when held, J when tapped
k = Ctrl when held, K when tapped
l = Opt when held, L when tapped
; = Cmd when held, ; when tapped
```

**Example:**
```
Type: "sass" → s a s s (normal)
Hold: a+c = Cmd+C (copy)
Hold: s+tab = Opt+Tab (app switcher)
```

**Implementation with Karabiner:**

```json
// File: karabiner/.config/karabiner/karabiner.json (simplified)
{
  "rules": [
    {
      "description": "Home Row Mods - Left Hand",
      "manipulators": [
        {
          "type": "basic",
          "from": { "key_code": "a" },
          "to": [ { "key_code": "a" } ],
          "to_if_held_down": [ { "key_code": "left_command" } ],
          "parameters": {
            "basic.to_if_held_down_threshold_milliseconds": 150
          }
        }
        // ... s, d, f similar
      ]
    }
  ]
}
```

**Timing tuning:**

| Threshold | Tap "a" twice | Hold "a" for mod | Typing "sass" |
|-----------|---------------|------------------|---------------|
| **50ms** | Works | ✅ Fast | ❌ Triggers mod |
| **150ms** | Works | ✅ Good | ✅ Works |
| **300ms** | Works | ❌ Laggy | ✅ Works |

**Sweet spot: 150ms**
- Slow enough to avoid accidental triggers
- Fast enough to feel responsive
- Tuned for 70+ WPM typing speed

**Learning curve:**

**Week 1:**
- Constant accidental modifiers
- Frustrating, want to quit
- Type slower to avoid triggers

**Week 2:**
- Starting to feel natural
- Still occasional mistakes
- Speed recovering

**Month 1:**
- Muscle memory locked in
- Faster than before
- No wrist pain

**Month 2+:**
- Can't live without it
- Traditional keyboards feel wrong
- Evangelizing to friends

**Real-world usage:**

```bash
# Copy line in shell
Cmd+A (a+home) → select all
Cmd+C (a+c) → copy
# No pinky stretch!

# Vim-style app switching
Opt+Tab (s+tab) → switch apps
Opt+Shift+Tab (s+f+tab) → reverse
# Home row stays home

# Terminal shortcuts
Cmd+T (a+t) → new tab
Cmd+W (a+w) → close tab
Ctrl+C (d+c) → interrupt
# All with home row
```

**Trade-off:**
- Week 1-2: Slower typing (learning curve)
- Double letters (sass, fall) need slight pause
- Must install Karabiner (not built-in)

**We accept this for:**
- Zero wrist pain (ergonomic win)
- Faster long-term (no hand movement)
- Works system-wide (not just shell)

---

## Troubleshooting

### Diagnostic Commands

**Shell startup too slow?**
```bash
# Measure total time
$ time zsh -i -c exit
zsh -i -c exit  0.08s user 0.03s system 95% cpu 0.085 total
# Target: <100ms (0.100s)

# Profile with zprof
$ zsh -i -c 'zmodload zsh/zprof && source ~/.config/zsh/.zshrc && zprof'
# Shows time per function

# Check specific module
$ time zsh -c 'source ~/.config/zsh/modules/06-plugins.zsh'
# Isolate slow modules
```

**Plugins not loading?**
```bash
# List installed plugins
$ antidote list
zsh-users/zsh-syntax-highlighting
zsh-users/zsh-autosuggestions
zsh-users/zsh-completions
zsh-users/zsh-history-substring-search

# Force update
$ antidote update

# Force regenerate static file
$ rm ~/.config/zsh/.zsh_plugins.zsh && exec zsh
```

**Completions broken?**
```bash
# Clear completion cache
$ rm -f ~/.cache/zsh/.zcompdump*

# Regenerate
$ exec zsh

# Verify completion system loaded
$ echo $fpath
# Should include /usr/share/zsh/site-functions

# Test specific completion
$ git <tab>
# Should show git subcommands
```

**Homebrew not in PATH?**
```bash
# Check PATH in non-login shell
$ zsh -c 'echo $PATH'
# Should include /opt/homebrew/bin

# If not, check .zshenv
$ grep -n "brew shellenv" ~/.zshenv
17:eval "$(/opt/homebrew/bin/brew shellenv)"

# Verify Homebrew location
$ /opt/homebrew/bin/brew --version
Homebrew 4.2.0

# If error, reinstall Homebrew
$ /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

**Vi mode cursor not changing?**
```bash
# Test DECSCUSR escape codes
$ echo -ne '\e[1 q'  # Should show block cursor
$ echo -ne '\e[5 q'  # Should show beam cursor

# If not working, check terminal support
# WezTerm: works automatically
# iTerm2: Preferences → Profiles → Text → Cursor → Enable "Cursor boost"

# Verify ZLE hooks registered
$ zle -l | grep keymap
zle-keymap-select
```

**Stow conflicts?**
```bash
# Check for existing files
$ ls -la ~/.config/zsh/.zshrc
lrwxr-xr-x  ... .zshrc -> ../../dotfiles/zsh/.config/zsh/.zshrc

# If symlink broken
$ stow -D zsh  # Unstow
$ stow -v zsh  # Re-stow with verbose

# If file exists (not symlink)
$ mv ~/.config/zsh/.zshrc ~/.config/zsh/.zshrc.backup
$ stow zsh
```

### Common Issues with Solutions

**Issue: "command not found: brew" in WezTerm**

**Symptom:**
```bash
$ brew --version
zsh: command not found: brew
```

**Cause:** Homebrew in `.zprofile` (login only), WezTerm domains are non-login shells.

**Solution:**
```bash
# Move Homebrew to .zshenv
$ nvim ~/.zshenv
# Add: eval "$(/opt/homebrew/bin/brew shellenv)"

$ exec zsh
$ brew --version
Homebrew 4.2.0  ✅
```

**Reference:** `dot-zshenv/.zshenv:17`

---

**Issue: Plugins load slowly (30-50ms)**

**Symptom:**
```bash
$ time zsh -i -c exit
0.150s  # Slower than target
```

**Cause:** Dynamic plugin loading (regenerates every shell).

**Solution:**
```bash
# Check if using static loading
$ cat ~/.config/zsh/modules/06-plugins.zsh | grep -A5 "if \[\["
if [[ ! ${zsh_plugins}.zsh -nt ${zsh_plugins}.txt ]]; then
  # Only regenerates if .txt changed ✅
fi

# If missing, add static loading pattern
# Reference: zsh/.config/zsh/modules/06-plugins.zsh:12-19
```

---

**Issue: NVM slows startup by 200ms**

**Symptom:**
```bash
$ zprof | grep nvm
nvm    1  198.45ms
```

**Cause:** Loading NVM at startup.

**Solution:** Lazy load NVM
```bash
# File: zsh/.config/zsh/modules/05-tools.zsh:8-18
nvm() {
  unset -f nvm
  [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
  nvm "$@"
}

# Now startup fast, first `nvm` call slow (acceptable)
```

---

**Issue: Completion menu not using vi keys**

**Symptom:** hjkl doesn't work in completion menu.

**Cause:** `zsh/complist` not loaded or bindings not set.

**Solution:**
```bash
# Add to keybindings
zmodload zsh/complist
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'j' vi-down-line-or-history
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char

# Reference: zsh/.config/zsh/modules/04-keybindings.zsh:36-41
```

---

## Learning Path

### Week 1: Core Setup

**Goals:**
- Install and verify basic functionality
- Learn basic vi mode movements
- Understand Quick Start workflow

**Tasks:**
```bash
# 1. Install dotfiles
cd ~/dotfiles && ./install.sh && exec zsh

# 2. Verify startup time
time zsh -i -c exit  # Should be <100ms

# 3. Practice vi mode
# Insert mode (default): type normally
# Command mode: press jk or Esc
# Movement: h j k l (left down up right)
# Delete word: dw
# Change word: cw

# 4. Try fzf
Ctrl+R  # Search history
Ctrl+T  # Search files
Alt+C   # Search directories

# 5. Use modern tools
ls      # Actually eza
cat foo # Actually bat
cd ~    # Then: z dotfiles (zoxide)
```

**Resources:**
- [Vi mode cheatsheet](https://devhints.io/zsh)
- [fzf examples](https://github.com/junegunn/fzf#usage)

### Week 2: Customization

**Goals:**
- Add personal aliases
- Customize colors
- Understand module system

**Tasks:**
```bash
# 1. Add custom aliases
nvim ~/.config/zsh/modules/03-aliases.zsh
# Add: alias myalias='command'
source ~/.config/zsh/modules/03-aliases.zsh  # Test
exec zsh  # Verify

# 2. Explore Starship config
nvim ~/.config/starship.toml
# Change prompt symbols, colors, modules

# 3. Add custom ZSH module
nvim ~/.config/zsh/modules/08-custom.zsh
# Add your functions/aliases
# Auto-loads (numbered module)

# 4. Customize fzf colors (optional)
nvim ~/.config/zsh/modules/07-modern-tools.zsh
# Tweak FZF_DEFAULT_OPTS colors

# 5. Commit changes
cd ~/dotfiles
git add .
git commit -m "feat: personal customizations"
```

### Month 1: Advanced Usage

**Goals:**
- Master vi mode
- Optimize performance
- Understand architecture

**Tasks:**
```bash
# 1. Advanced vi mode
# Learn: ci" (change inside quotes)
#        dt. (delete till period)
#        yiw (yank inner word)
#        V (visual line mode)

# 2. Profile startup
zsh -i -c 'zmodload zsh/zprof && source ~/.zshrc && zprof'
# Identify slow modules
# Consider lazy loading

# 3. Customize completions
nvim ~/.config/zsh/modules/02-options.zsh
# Tweak completion styles, colors

# 4. Add plugin (if needed)
nvim ~/.config/zsh/.zsh_plugins.txt
# Add: username/repo-name
rm ~/.config/zsh/.zsh_plugins.zsh  # Force regen
exec zsh

# 5. Read Architecture section
# Understand XDG, shell init order, static loading
```

### Month 2+: Mastery

**Goals:**
- Contribute improvements
- Help others
- Customize for your workflow

**Ideas:**
- Write custom ZSH functions for your workflow
- Create language-specific modules (09-python.zsh)
- Tune Home Row Mods timing for your speed
- Share your dotfiles repo
- Blog about what you learned

---

## Further Reading

### Essential Resources

**ZSH:**
- [ZSH Guide](https://zsh.sourceforge.io/Guide/) - Official comprehensive guide
- [ZSH Lovers](https://grml.org/zsh/zsh-lovers.html) - Tips and tricks collection
- [Writing ZSH Completion Functions](https://github.com/zsh-users/zsh-completions/blob/master/zsh-completions-howto.org)

**Dotfiles:**
- [XDG Base Directory Specification](https://specifications.freedesktop.org/basedir-spec/basedir-spec-latest.html)
- [GNU Stow Manual](https://www.gnu.org/software/stow/manual/stow.html)
- [Dotfiles community](https://dotfiles.github.io/) - Curated list of dotfile repos

**Tools:**
- [Antidote Documentation](https://getantidote.github.io/)
- [Starship Configuration](https://starship.rs/config/)
- [WezTerm Documentation](https://wezfurlong.org/wezterm/)
- [Aerospace Window Manager](https://github.com/nikitabobko/AeroSpace)
- [Tokyo Night Theme](https://github.com/folke/tokyonight.nvim)

**Vi Mode:**
- [ZSH Vi Mode Reference](https://zsh.sourceforge.io/Doc/Release/Zsh-Line-Editor.html#Zle-Widgets)
- [Vi Cheatsheet](https://devhints.io/vim)

**Home Row Mods:**
- [Karabiner-Elements Documentation](https://karabiner-elements.pqrs.org/docs/)
- [Home Row Mods Guide](https://precondition.github.io/home-row-mods)

---

## License

MIT - Feel free to use, modify, and share.

---

**Feedback welcome!** Open an issue or PR at your repository.

**Built with:** ZSH, Antidote, Stow, Tokyo Night, WezTerm, Aerospace, Karabiner, Neovim, and love for fast shells.
