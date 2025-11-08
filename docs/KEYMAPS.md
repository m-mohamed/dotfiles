# Essential Keymaps Cheat Sheet

Your 80/20 guide to daily workflows with WezTerm, Neovim, and Aerospace.

---

## Quick Reference

### Most Used (Commit to Muscle Memory)
```
WezTerm:     Ctrl+a → s/v/h/j/k/l/q/z/t/[/]
Neovim:      Space Space / gd / gr / K / Space ca / Shift+H/L
Aerospace:   Alt+h/j/k/l / Alt+b/t/d / Alt+Shift+h/j/k/l / Alt+Tab
```

### Navigation Hierarchy
```
Level 1: Workspaces (Aerospace)     → Alt+b/t/d/m/s/e
Level 2: Windows (Aerospace)        → Alt+h/j/k/l
Level 3: Terminal Panes (WezTerm)   → Ctrl+a → h/j/k/l
Level 4: Editor Buffers (Neovim)    → Shift+H/L
Level 5: Editor Splits (Neovim)     → Ctrl+h/j/k/l
```

---

## 1. WezTerm Terminal Multiplexer

### Leader Key
**`Ctrl+a`** (1 second timeout) - Screen/Tmux standard for better ergonomics

### Top 7 Essential Keymaps (Daily, 10x/day)

| Keymap | Action | Notes |
|--------|--------|-------|
| `Ctrl+a` → `s` | Split pane vertically | Creates horizontal split |
| `Ctrl+a` → `v` | Split pane horizontally | Creates vertical split |
| `Ctrl+a` → `h/j/k/l` | Navigate panes (vim-style) | Focus left/down/up/right |
| `Ctrl+a` → `q` | Close current pane | No confirmation |
| `Ctrl+a` → `z` | Zoom/maximize pane | Toggle fullscreen for current pane |
| `Ctrl+a` → `t` | New tab | Create in current domain |
| `Ctrl+a` → `[` / `]` | Previous/next tab | Quick tab switching |

### Next 7 Important Keymaps (Regular use)

| Keymap | Action | Notes |
|--------|--------|-------|
| `Ctrl+a` → `b` | Show tab navigator | Visual tab picker |
| `Ctrl+a` → `r` | Rename tab | Prompt for new name |
| `Ctrl+a` → `Shift+H/L` | Move tab left/right | Reorder tabs |
| `Ctrl+a` → `w` | Show workspaces | Workspace launcher |
| `Ctrl+a` → `e` | Switch workspace | Prompt for workspace name |
| `Ctrl+a` → `Space` | QuickSelect | Select URLs, paths, git SHAs |
| `Ctrl+a` → `a/d` | Attach/detach session | Unix domain persistence |

### Other Useful Features

- **Font size**: `Ctrl+` / `Ctrl-` / `Ctrl+0` (reset)
- **Copy/Paste**: `Cmd+C` / `Cmd+V`
- **Clear scrollback**: `Cmd+K`
- **Scroll**: `Shift+PageUp/Down`
- **Right-click paste** from clipboard
- **Ctrl+scroll** to zoom
- **Persistent sessions** via Unix domain (auto-connects on startup)

### Configuration Highlights

- Font: JetBrainsMono Nerd Font, size 22
- Color scheme: Tokyo Night
- 10,000 line scrollback
- Pane focus follows mouse
- Tab bar at bottom, always visible
- Unix domain for session persistence

---

## 2. Neovim (LazyVim Distribution)

### Leader Key
**`Space`** (default LazyVim)

### Important Note: Disabled Keybindings
**Alt+j/k** line movement has been disabled to prevent conflicts with Aerospace window navigation.
**Alternatives:** Use `]e` / `[e` for line movement, or visual mode + `:m` commands.

### Top 10 Essential Keymaps (Daily coding)

| Keymap | Action | Usage |
|--------|--------|-------|
| `Space` → `Space` | Find files (root) | Primary file navigation |
| `Space` → `/` | Grep search (root) | Search in files |
| `Ctrl+h/j/k/l` | Navigate windows | Move between splits |
| `gd` | Go to definition | Jump to symbol definition |
| `gr` | Find references | Show all references |
| `K` | Hover docs | LSP documentation |
| `Space` → `ca` | Code action | Quick fixes, refactoring |
| `Space` → `cr` | Rename symbol | LSP rename |
| `Shift+H/L` | Previous/next buffer | Buffer navigation |
| `Space` → `-` / `\|` | Split below/right | Create splits |

### Next 10 Important Keymaps (Regular use)

| Keymap | Action | Usage |
|--------|--------|-------|
| `Space` → `ff` | Find files | Same as `Space Space` |
| `Space` → `fb` / `,` | Buffer list | Switch buffers |
| `Space` → `bd` | Delete buffer | Close current buffer |
| `Space` → `cf` | Format code | Auto-format |
| `Space` → `cd` | Line diagnostics | Show errors/warnings |
| `]d` / `[d` | Next/prev diagnostic | Navigate errors |
| `gI` | Go to implementation | Jump to implementation |
| `n` / `N` | Next/prev search | Navigate search results |
| `Space` → `sr` | Search and replace | Project-wide replace |
| `Space` → `wd` | Delete window | Close split |

### UI Toggles & Utilities

| Keymap | Action |
|--------|--------|
| `Space` → `uf` | Toggle auto-format |
| `Space` → `ud` | Toggle diagnostics |
| `Space` → `ul` | Toggle line numbers |
| `Space` → `uw` | Toggle word wrap |
| `Space` → `uz` | Toggle zen mode |
| `:w` | Save file (classic vim) |

### Configuration Notes

- Using LazyVim distribution (well-documented defaults)
- Custom keymaps file is empty (sticking with LazyVim conventions)
- Tokyo Night color scheme (matching WezTerm and system)

---

## 3. Aerospace Window Manager

### Mod Key
**`Alt`** (Option key on macOS)

### Top 10 Essential Keymaps (Daily window management)

| Keymap | Action | Notes |
|--------|--------|-------|
| `Alt+h/j/k/l` | Focus window (vim-style) | Navigate between windows |
| `Alt+Shift+h/j/k/l` | Move window | Move window in direction |
| `Alt+b/t/d/m/s/e` | Switch workspace | Browser/Terminal/Dev/Media/Slack/Email |
| `Alt+Shift+b/t/m/s` | Move to workspace | Move window + mnemonic key |
| `Alt+Tab` | Toggle last workspace | Back and forth |
| `Alt+Shift+f` | Toggle fullscreen | Maximize current window |
| `Alt+/` | Toggle layout | Tiles horizontal/vertical |
| `Alt+,` | Accordion layout | Stacked windows |
| `Alt+Space` | Service mode | Advanced operations modal |
| `Alt+r` | Resize mode | Enter resize mode |

### Next 10 Important Keymaps (Regular use)

| Keymap | Action | Notes |
|--------|--------|-------|
| `Alt+Shift+Space` | Float/tile toggle | Toggle floating window |
| `Alt+p/n` | Prev/next monitor | Focus different display |
| `Alt+Shift+p/n` | Move to monitor | Move window to display |
| `Alt+u/i` | Prev/next workspace | Sequential navigation |
| `Alt+w` | Workspace mode | Workspace navigation modal |
| `Ctrl+Shift+d` | Move to Dev workspace | Alt conflict workaround |
| `Ctrl+Shift+e` | Move to Email workspace | Alt conflict workaround |
| `Alt+Shift+Tab` | Move workspace to monitor | Workspace to next display |
| `Alt+Shift+-/=` | Quick resize | Shrink/grow by 50px |

### Modal Modes

#### Service Mode (`Alt+Space`)

| Keymap | Action |
|--------|--------|
| `f` | Toggle floating → exit |
| `b` | Balance window sizes → exit |
| `h/j/k/l` | Join windows (vim-style) → exit |
| `Backspace` | Close all but current → exit |
| `-` | Flatten layout (reset) → exit |
| `Esc/Space/Enter` | Exit to main mode |

#### Resize Mode (`Alt+r`)

| Keymap | Action |
|--------|--------|
| `h/j/k/l` | Resize by 50px (vim-style) |
| `Shift+h/j/k/l` | Fine resize by 10px |
| `b` | Balance sizes → exit |
| `Esc/Space/Enter` | Exit to main mode |

#### Workspace Mode (`Alt+w`)

| Keymap | Action |
|--------|--------|
| `h/l` | Prev/next workspace → exit |
| `j/k` | Next/prev monitor → exit |
| `b/t/d/m/s/e` | Go to workspace → exit |
| `Shift+b/t/d/m/s/e` | Move window + follow → exit |
| `Esc/Space/Enter` | Exit to main mode |

### Workspace Layout

- **B**: Browser
- **T**: Terminal (WezTerm lives here)
- **D**: Development (Neovim coding)
- **M**: Media
- **S**: Slack/Communication
- **E**: Email

### Configuration Highlights

- Gaps: 10px inner, 10px sides, 30px top/bottom (floating aesthetic)
- Mouse follows focus (window-lazy-center)
- Default: tiling layout, auto orientation
- Borders integration (blue active, gray inactive, 6px rounded)

---

## Daily Workflow Patterns

### Pattern 1: Start New Project
```bash
Alt+t               # Switch to Terminal workspace
Ctrl+a → t          # New WezTerm tab
cd ~/projects/foo   # Navigate to project
nvim .              # Open Neovim
Alt+d               # Switch to Dev workspace (Neovim auto-moves)
```

### Pattern 2: Split Terminal + Editor
```bash
Alt+t               # Terminal workspace
Ctrl+a → s          # Split WezTerm vertically
# Top pane: run dev server
# Bottom pane: git commands
Alt+d               # Switch to Neovim for coding
Alt+Tab             # Toggle back to terminal
```

### Pattern 3: Multi-Pane Development
```bash
Alt+d               # Dev workspace
Space Space         # Find file in Neovim
Space -             # Split Neovim window below
Ctrl+j/k            # Navigate between splits
Space cf            # Format code
Alt+t               # Quick check terminal
```

### Pattern 4: Reference + Code Split
```bash
Alt+b               # Browser workspace
# Open documentation
Alt+d               # Dev workspace
Alt+Shift+b         # Move browser window to Dev workspace
Alt+h/l             # Navigate between browser and editor
Alt+/               # Toggle layout if needed
```

### Pattern 5: Quick Search & Edit
```bash
Space /             # Grep in Neovim
# Find the text
Enter               # Jump to result
gd                  # Go to definition
Space ca            # Code action / quick fix
Space cf            # Format
:w                  # Save
Alt+t               # Switch to terminal
git add -p          # Stage changes
```

### Pattern 6: Persistent Session Workflow
```bash
# Morning: WezTerm auto-attaches to unix domain
# All tabs/panes/workspaces from yesterday restored
Ctrl+a → b          # Show tab navigator
# Pick up where you left off

# Evening: Just close terminal
# State persists automatically via unix domain
```

---

## Integration & Tool Synergy

### WezTerm ↔ Neovim

- Open files: `nvim filename` from any WezTerm pane
- Shell from Neovim: `Space x` (LazyVim terminal toggle)
- Copy between: System clipboard (`Cmd+C/V`) works everywhere

### Aerospace ↔ WezTerm

- WezTerm typically lives in workspace T
- Can split WezTerm window with Aerospace (`Alt+/`)
- WezTerm pane management is independent of Aerospace windows
- Use WezTerm panes for terminal multiplexing, Aerospace for app windows

### Aerospace ↔ Neovim

- Neovim typically in workspace D
- Can tile multiple Neovim instances if needed
- Neovim splits are internal; Aerospace manages the window
- Use `Alt+Shift+f` for fullscreen focus mode

### Color Scheme Unity

- All three tools use Tokyo Night theme
- Visual consistency across the stack

---

## Power User Tips

### 1. Workspace Discipline

- Keep workspace assignments consistent
- B=Browser, T=Terminal, D=Dev, M=Media, S=Slack, E=Email
- Use `Alt+Tab` to toggle between two main workspaces

### 2. Modal Efficiency

- Learn the three Aerospace modes (service, resize, workspace)
- Service mode for quick operations, exits automatically
- Resize mode for window adjustments, stay in mode

### 3. Pane vs Window Strategy

- **WezTerm panes**: Related terminal tasks (server + logs + git)
- **Aerospace windows**: Different apps (browser + editor + terminal)
- Don't over-nest: 2-3 WezTerm panes per tab is the sweet spot

### 4. Session Persistence

- WezTerm unix domain = tmux-like persistence without tmux
- Survives terminal crashes, restarts
- `Ctrl+a → a/d` to manually attach/detach if needed

### 5. Quick Context Switching

- `Alt+Tab`: Toggle between two main workspaces
- `Shift+H/L` in Neovim: Quick buffer switching
- `Ctrl+a → [/]`: WezTerm tab switching
- Master these three for 90% of navigation

---

## Learning Path

### Week 1: Foundation (Commit These First)

```
Alt+b/t/d           # Workspace switching
Space Space         # Find files
Ctrl+a → s/v/h/j/k/l # Terminal panes
```

**Goal**: Navigate between apps and create terminal splits without thinking.

### Week 2: Code Navigation

```
Alt+h/j/k/l         # Window focus
gd / gr / K         # Code navigation
Alt+Tab             # Workspace toggle
```

**Goal**: Move between windows and jump through code efficiently.

### Week 3: Advanced Operations

```
Alt+Space           # Service mode
Space ca / Space cr # Code actions
Modal modes         # Resize, workspace
```

**Goal**: Handle complex window operations and refactoring.

### Week 4: Mastery

- Combine workflows without thinking
- Use modal modes naturally
- Custom workspace organization for your projects

---

## Troubleshooting

### "Keybind not working"

- Check if app has focus (Aerospace manages focused app)
- Some apps capture certain key combinations
- Use `Alt+Space` service mode as fallback

### "Lost in splits/panes/windows"

- `Ctrl+a → z` to zoom current WezTerm pane
- `Alt+Shift+f` to fullscreen current window
- `Ctrl+a → b` for visual tab navigator

### "Can't find my window"

- `Alt+Tab` likely toggles to it
- `Alt+w` opens workspace mode for overview
- Check other workspaces with `Alt+b/t/d/m/s/e`

### "Want to reset layout"

- `Alt+Space → -` flattens Aerospace layout
- `Alt+Space → b` balances window sizes
- Restart Aerospace if needed

---

## Configuration Files

- **WezTerm**: `~/.config/wezterm/wezterm.lua`
- **Neovim**: `~/.config/nvim/lua/config/keymaps.lua`
- **Aerospace**: `~/.config/aerospace/aerospace.toml`

All managed via GNU Stow from `~/dotfiles`.

---

## Further Reading

- [LazyVim Keymaps Documentation](https://www.lazyvim.org/keymaps)
- [Aerospace Window Manager Docs](https://github.com/nikitabobko/AeroSpace)
- [WezTerm Configuration](https://wezfurlong.org/wezterm/config/files.html)
- [Comprehensive Setup Guide](GUIDE.md) - Architecture, design decisions, troubleshooting

---

**Built with:** WezTerm, LazyVim, Aerospace, Tokyo Night, and love for vim keybindings.
