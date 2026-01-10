# Tool Configuration Reference

Quick reference for the key tools in this dotfiles setup. For detailed configuration, see the source files.

---

## Ghostty (Terminal)

**Config:** `ghostty/.config/ghostty/config`

Fast, native terminal emulator. Used as display layer for tmux.

### Key Settings

- Launches tmux automatically on start
- Tokyo Night theme (built-in)
- JetBrainsMono Nerd Font @ 22pt

### Keybindings (Minimal)

| Key | Action |
|-----|--------|
| `Cmd+C/V` | Copy/paste |
| `Cmd+±` | Font size |
| `Cmd+K` | Clear screen |

All navigation happens in tmux with `Ctrl+a` prefix. See Tmux section below.

---

## Tmux (Session Manager)

**Config:** `tmux/.config/tmux/tmux.conf`

### Key Concepts

- **Prefix:** `Ctrl+a` (screen standard)
- **Persistent sessions:** Survive terminal crashes, accessible via SSH
- **Plugins:** TPM, resurrect, continuum, yank

### Essential Keybindings

| Key | Action |
|-----|--------|
| `Ctrl+a w` | Session/window chooser |
| `Ctrl+a h/j/k/l` | Navigate panes (vim-style) |
| `Ctrl+a s` | Split horizontal |
| `Ctrl+a v` | Split vertical |
| `Ctrl+a z` | Toggle pane zoom |
| `Ctrl+a q` | Close pane |
| `Ctrl+a t` | New window |
| `Ctrl+a [/]` | Previous/next window |
| `Ctrl+a d` | Detach |
| `Alt+1-9` | Direct window access |

### Modern Popups

| Key | Action |
|-----|--------|
| `Ctrl+a Ctrl+w` | Session switcher (fzf popup) |
| `Ctrl+a Ctrl+t` | Scratch terminal |
| `Ctrl+a g` | Floating lazygit |

### Shell Aliases

| Alias | Command |
|-------|---------|
| `tb` | `tmux-boot` (project launcher) |
| `ta <name>` | Attach to session |
| `tl` | List sessions |
| `tn <name>` | New session |
| `tk <name>` | Kill session |
| `tmux-nuke` | Kill all sessions |

---

## Aerospace (Window Manager)

**Config:** `aerospace/.config/aerospace/aerospace.toml`

### Philosophy

- **Tiling by default** - Windows automatically tile
- **Vim-style navigation** - `Alt+h/j/k/l` to move focus
- **Mnemonic workspaces** - B(rowser), T(erminal), D(ev), M(edia), S(lack), E(mail)
- **Modal modes** - Service, Resize, Workspace modes for advanced operations

### Main Mode (Default)

| Key | Action |
|-----|--------|
| `Alt+h/j/k/l` | Focus window (vim-style) |
| `Alt+Shift+h/j/k/l` | Move window |
| `Alt+Shift+f` | Toggle fullscreen |
| `Alt+Shift+Space` | Toggle floating/tiling |
| `Alt+/` | Horizontal layout |
| `Alt+,` | Accordion (stacked) layout |
| `Alt+Tab` | Back and forth between workspaces |

### Workspace Navigation

| Key | Action |
|-----|--------|
| `Alt+b/t/d/m/s/e` | Switch to workspace B/T/D/M/S/E |
| `Alt+Shift+b/t/...` | Move window to workspace |
| `Alt+u/i` | Previous/next workspace |
| `Alt+p/n` | Previous/next monitor |

### Modes

| Key | Mode |
|-----|------|
| `Alt+Space` | Service mode (join, balance, close-all) |
| `Alt+r` | Resize mode |
| `Alt+w` | Workspace mode |

Press `Esc` or `Space` to exit any mode.

### Service Mode Bindings

| Key | Action |
|-----|--------|
| `h/j/k/l` | Join window with neighbor |
| `b` | Balance window sizes |
| `-` | Flatten workspace tree |
| `Backspace` | Close all windows except current |

---

## Karabiner (Keyboard)

**Config:** `karabiner/.config/karabiner/karabiner.json`

### Home Row Mods

Hold home row keys to activate modifiers (150ms threshold):

| Key | Tap | Hold |
|-----|-----|------|
| `a` | a | Command |
| `s` | s | Option |
| `d` | d | Control |
| `f` | f | Shift |
| `j` | j | Shift |
| `k` | k | Control |
| `l` | l | Option |
| `;` | ; | Command |

### Other Remaps

| Key | Action |
|-----|--------|
| `Caps Lock` | Escape |

### Tuning Parameters

- `to_if_alone_timeout`: 150ms - Time to register single tap
- `to_if_held_down_threshold`: 250ms - Time to register hold

Increase these values if you're getting accidental modifier activations.

---

## Sketchybar (Status Bar)

**Config:** `sketchybar/.config/sketchybar/`

### Architecture

```
sketchybarrc          # Main config (loads colors, icons, items)
colors.sh             # Tokyo Night color definitions
icons.sh              # Icon symbols
items/                # UI component definitions
  ├── apple.sh        # Apple menu
  ├── spaces.sh       # Aerospace workspace indicators
  └── ...
plugins/              # Event handlers and data fetchers
  ├── aerospace.sh    # Workspace change handler
  ├── battery.sh      # Battery monitoring
  ├── clock.sh        # Time display
  └── ...
```

### Integration Points

- **Aerospace:** Triggers `aerospace_workspace_change` event on workspace switch
- **System Stats:** Uses `sketchybar-system-stats` for CPU/memory/battery

### Customization

Colors are defined in `colors.sh` using Tokyo Night palette:
```bash
export BAR_COLOR=0xff1a1b26      # Background
export ICON_COLOR=0xffc0caf5     # Icons
export LABEL_COLOR=0xffc0caf5    # Text
```

---

## Starship (Prompt)

**Config:** `starship/.config/starship.toml`

### Features

- Multi-line prompt with directory icons
- Git branch and status
- Language version indicators (Node, Rust, Go, Python)
- Time display
- Tokyo Night color scheme

---

## Development Stack

### TypeScript/JavaScript

- **Runtime:** Bun (fast, Node-compatible)
- **Linter/Formatter:** Biome

### Python

- **Package Manager:** uv (fast pip alternative)
- **Linter:** Ruff
- **Type Checker:** Basedpyright (install via `pipx install basedpyright`)

### Installation

```bash
brew bundle install  # Installs bun, biome, uv, ruff from Brewfile
pipx install basedpyright  # Type checker
```
