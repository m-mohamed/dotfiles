# Deep Dive: WezTerm, AeroSpace & LazyVim

This guide provides an in-depth exploration of the three powerhouse tools in your development environment. Understanding these tools will unlock next-level productivity.

## Table of Contents
- [WezTerm: The Modern Terminal](#wezterm-the-modern-terminal)
- [AeroSpace: The Tiling Window Manager](#aerospace-the-tiling-window-manager)
- [LazyVim: The Neovim Distribution](#lazyvim-the-neovim-distribution)
- [Integration & Workflows](#integration--workflows)

---

## WezTerm: The Modern Terminal

WezTerm is a GPU-accelerated terminal emulator written in Rust, configured with Lua. It's the foundation of your development environment.

### Why WezTerm?

**vs iTerm2:**
- WezTerm: Lua config (programmable), Unix domains (persistent), cross-platform
- iTerm2: GUI config, macOS-only, feature-rich but less hackable

**vs Alacritty:**
- WezTerm: Full multiplexing, tabs, splits, domain support
- Alacritty: Minimal, fastest possible, delegates to tmux for multiplexing

**vs Kitty:**
- WezTerm: Unix domains eliminate need for tmux, better window management
- Kitty: Image protocol, GPU rendering, Python extensions

### Core Concepts

#### 1. Unix Domains (The Game Changer)

**Traditional terminal lifecycle:**
```
Terminal → Spawn shell → Work → Close terminal → Shell dies → Work lost
```

**WezTerm Unix Domains:**
```
Terminal → Connect to domain → Work → Close terminal → Domain persists
         → Reopen terminal → Auto-reconnect → Resume exactly where you left off
```

**Your configuration:**
```lua
-- wezterm/.config/wezterm/wezterm.lua:44-53
config.unix_domains = {
  {
    name = "unix",
    connect_automatically = true,  -- Auto-connect on startup
  },
}

config.default_gui_startup_args = { "connect", "unix" }
config.window_close_confirmation = "AlwaysPrompt"  -- Safety net
```

**What this means:**
- Your shell sessions survive terminal restarts
- Tabs and splits persist across reboots
- No need for tmux/screen for persistence
- Fast reconnection (no startup lag)

**Critical insight:** This is why Homebrew MUST be in `.zshenv` (not `.zprofile`). Domain shells are non-login shells!

#### 2. Leader Key Pattern

WezTerm uses a leader key (like tmux) to avoid conflicts with shell and editor keybindings.

**Your leader: Ctrl+G**

```lua
-- wezterm/.config/wezterm/wezterm.lua:30
config.leader = { key = "g", mods = "CTRL", timeout_milliseconds = 1000 }
```

**Pattern:**
1. Press `Ctrl+G` (leader activates, shown in status bar)
2. Within 1 second, press command key
3. Leader auto-releases after command

**Why Ctrl+G?**
- Doesn't conflict with common shortcuts (Ctrl+A = tmux, Ctrl+B = tmux default)
- Easy to reach (home row adjacent)
- Not used by vim or ZSH vi-mode
- Mnemonic: "G" for "Go" (navigate/control)

#### 3. Pane Management (Vim-Inspired)

**Philosophy:** Same keybindings as Vim splits.

```lua
-- Split panes
Ctrl+G s    -- Split vertically (new pane below) - like :split in Vim
Ctrl+G v    -- Split horizontally (new pane right) - like :vsplit in Vim

-- Navigate panes (vim hjkl)
Ctrl+G h    -- Focus left
Ctrl+G j    -- Focus down
Ctrl+G k    -- Focus up
Ctrl+G l    -- Focus right

-- Pane operations
Ctrl+G z    -- Zoom pane (toggle fullscreen) - like Ctrl+W | in Vim
Ctrl+G q    -- Close pane (no confirm) - like :q in Vim
```

**Your configuration:**
```lua
-- wezterm/.config/wezterm/wezterm.lua:220-259
{
  key = "s",
  mods = "LEADER",
  action = act.SplitVertical({ domain = "CurrentPaneDomain" }),
},
-- ... h/j/k/l navigation
```

**Pane visual feedback:**
```lua
-- wezterm/.config/wezterm/wezterm.lua:16-19
config.inactive_pane_hsb = {
  saturation = 0.8,  -- 20% desaturated
  brightness = 0.7,  -- 30% dimmed
}
```

Inactive panes are visually muted so you always know where focus is.

#### 4. Tab Management

**Tabs vs Panes vs Workspaces:**
- **Panes**: Multiple shells in one view (side by side)
- **Tabs**: Multiple groups of panes (like browser tabs)
- **Workspaces**: Collections of tabs (like virtual desktops)

**Tab operations:**
```lua
Ctrl+G t        -- New tab
Ctrl+G ]        -- Next tab
Ctrl+G [        -- Previous tab
Ctrl+G c        -- Close tab (with confirmation)
Ctrl+G b        -- Show tab navigator (visual picker)
Ctrl+G r        -- Rename tab (prompt)
Ctrl+G Shift+H  -- Move tab left
Ctrl+G Shift+L  -- Move tab right
```

**Tab bar styling:**
```lua
-- wezterm/.config/wezterm/wezterm.lua:35-39
config.tab_bar_at_bottom = true
config.use_fancy_tab_bar = true
config.hide_tab_bar_if_only_one_tab = false  -- Always show
config.tab_max_width = 32
config.switch_to_last_active_tab_when_closing_tab = true
```

**Tokyo Night tab colors:**
```lua
-- wezterm/.config/wezterm/wezterm.lua:71-95
tab_bar = {
  background = "#1a1b26",
  active_tab = {
    fg_color = "#16161e",
    bg_color = "#7aa2f7",  -- Blue for active
  },
  inactive_tab = {
    fg_color = "#545c7e",
    bg_color = "#292e42",  -- Muted for inactive
  },
}
```

#### 5. Workspace Management

**Workspaces** are the highest level of organization: collections of tabs for different contexts.

**Use cases:**
- **Personal project**: Tabs for frontend, backend, docs
- **Work project**: Tabs for API, tests, database
- **Learning**: Tabs for tutorial, notes, experiments

**Workspace operations:**
```lua
Ctrl+G w        -- Show workspace picker (switch between existing)
Ctrl+G e        -- Switch to workspace by name (prompt)
Ctrl+G Shift+R  -- Rename current workspace
```

**Creating workspaces:**
```bash
# In WezTerm, use Ctrl+G e and type a new name
Ctrl+G e
> Type: "my-project"
# Creates new workspace and switches to it
```

**Status bar shows context:**
```lua
-- wezterm/.config/wezterm/wezterm.lua:168-184
wezterm.on("update-right-status", function(window, _)
  local domain_name = window:active_pane():get_domain_name() or "local"
  local workspace = window:active_workspace() or ""
  local process_name = window:active_pane():get_foreground_process_name() or ""

  -- Shows: [unix] | [my-project] | nvim
  window:set_right_status(domain .. workspace .. process_name)
end)
```

#### 6. Performance & Modern Features

**GPU acceleration:**
```lua
-- wezterm/.config/wezterm/wezterm.lua:150-152
config.front_end = "WebGpu"  -- Hardware acceleration
config.max_fps = 120         -- Silky smooth scrolling
config.animation_fps = 30    -- Smooth transitions
```

**Hyperlink detection:**
```lua
-- wezterm/.config/wezterm/wezterm.lua:107-113
config.hyperlink_rules = wezterm.default_hyperlink_rules()

-- Custom: Make "user/repo#123" clickable
table.insert(config.hyperlink_rules, {
  regex = [[\b[A-Za-z0-9-_]+/[A-Za-z0-9-_]+#\d+\b]],
  format = "https://github.com/$0",  -- user/repo#123 → GitHub issue
})
```

**QuickSelect for copying:**
```lua
Ctrl+G Space    -- QuickSelect mode

-- Patterns automatically detected:
-- - URLs: https://example.com
-- - File paths: ~/dotfiles/config.lua
-- - Git SHAs: abc1234567
-- - UUIDs: 550e8400-e29b-41d4-a716-446655440000
```

**Visual bell (no annoying beep):**
```lua
-- wezterm/.config/wezterm/wezterm.lua:137-143
config.audible_bell = "Disabled"
config.visual_bell = {
  fade_in_function = "EaseIn",
  fade_in_duration_ms = 150,
  fade_out_function = "EaseOut",
  fade_out_duration_ms = 150,
}
```

#### 7. Font & Display

```lua
-- wezterm/.config/wezterm/wezterm.lua:10-11
config.font_size = 22
config.font = wezterm.font("JetBrainsMono Nerd Font")
```

**Why JetBrains Mono Nerd Font?**
- Programming ligatures (→ becomes →, != becomes ≠)
- Excellent character distinction (0 vs O, 1 vs l vs I)
- Nerd Font = 3,600+ glyphs for icons
- Optimal at 14-22pt size

**No window padding:**
```lua
config.window_padding = {
  left = 0, right = 0, top = 0, bottom = 0,
}
```

Full screen space, AeroSpace handles gaps.

#### 8. Mouse Support

```lua
-- wezterm/.config/wezterm/wezterm.lua:116-134
config.mouse_bindings = {
  -- Right-click paste (like Linux terminals)
  {
    event = { Down = { streak = 1, button = "Right" } },
    mods = "NONE",
    action = act.PasteFrom("Clipboard"),
  },
  -- Ctrl+scroll to zoom
  {
    event = { Down = { streak = 1, button = { WheelUp = 1 } } },
    mods = "CTRL",
    action = act.IncreaseFontSize,
  },
}

-- Cmd+click for URLs (bypass shell mouse capture)
config.bypass_mouse_reporting_modifiers = "CMD"
```

#### 9. Session Persistence

**Attaching/Detaching from domain:**
```lua
Ctrl+G a    -- Attach to unix domain (reconnect)
Ctrl+G d    -- Detach from unix domain (disconnect but keep alive)
```

**Use case:** Detach before closing laptop, reattach after wake.

---

## AeroSpace: The Tiling Window Manager

AeroSpace is a tiling window manager for macOS, inspired by i3/sway but designed for macOS conventions.

### Why AeroSpace?

**vs yabai:**
- yabai: Powerful but requires disabling SIP (System Integrity Protection)
- AeroSpace: Works with SIP enabled, no system hacks needed

**vs Amethyst:**
- Amethyst: Auto-tiling (implicit, guesses what you want)
- AeroSpace: Manual tiling (explicit, you control everything)

**vs Rectangle:**
- Rectangle: Keyboard shortcuts for window snapping
- AeroSpace: Full tiling WM with workspaces and layouts

### Core Concepts

#### 1. Tiling Philosophy

**Traditional macOS:**
```
Windows float anywhere
↓
You manually resize and position
↓
Overlapping, chaos, constant adjustment
```

**Tiling window manager:**
```
Windows tile automatically
↓
Fill available space with no gaps/overlaps
↓
Keyboard-driven, predictable, efficient
```

**AeroSpace approach: Explicit control**
- You decide split direction (horizontal/vertical)
- Windows fill available space automatically
- No AI guessing, no auto-rearrangement

#### 2. Workspaces (Virtual Desktops)

**Your workspace configuration:**
```toml
# aerospace/.config/aerospace/aerospace.toml:120-127
Alt+B    # Browser workspace
Alt+T    # Terminal workspace
Alt+D    # Development workspace
Alt+M    # Media workspace
Alt+S    # Slack workspace
Alt+E    # Email workspace
```

**Mnemonic naming:**
- Not numbers (1, 2, 3) - hard to remember what's where
- Letters matching purpose (B for Browser)
- Instantly recall which workspace you need

**Workspace semantics:**
- Each workspace has independent window tree
- Workspaces are per-monitor
- Windows can be moved between workspaces

#### 3. Window Focus (Vim Keys)

**The foundation of all operations:**
```toml
# aerospace/.config/aerospace/aerospace.toml:93-97
Alt+h    # Focus left
Alt+j    # Focus down
Alt+k    # Focus up
Alt+l    # Focus right
```

**Why Alt modifier?**
- Doesn't conflict with terminal (Ctrl) or editor (Vim uses hjkl alone)
- macOS convention (Cmd+Tab, Cmd+Space)
- Easy to reach (thumb + index finger)

**Focus follows a tree structure:**
```
Workspace root
├── Left container
│   ├── Editor (focused)
│   └── Terminal
└── Right container
    ├── Browser
    └── Documentation
```

Press `Alt+l` → Focus moves to Browser.

#### 4. Window Movement

**Moving windows = restructuring the tree:**
```toml
# aerospace/.config/aerospace/aerospace.toml:99-103
Alt+Shift+h    # Move window left
Alt+Shift+j    # Move window down
Alt+Shift+k    # Move window up
Alt+Shift+l    # Move window right
```

**What "move" means:**
- Moves window in the tree structure
- Can change container hierarchy
- Windows automatically resize to fill space

**Example:**
```
Before:
[Editor][Terminal]

Alt+Shift+l (move Editor right):

After:
[Terminal][Editor]
```

#### 5. Layout Modes

**Tiles (Tiling Layout):**
```
┌─────────┬─────────┐
│         │         │
│    A    │    B    │
│         │         │
├─────────┴─────────┤
│         C         │
└───────────────────┘
```

All windows visible, space divided automatically.

**Accordion (Stacked Layout):**
```
┌───────────────────┐
│         A         │  ← Only A visible
├───────────────────┤
│  B (hidden below) │
├───────────────────┤
│  C (hidden below) │
└───────────────────┘
```

Only one window visible, others stacked (like tabs).

**Toggle layouts:**
```toml
# aerospace/.config/aerospace/aerospace.toml:90-91
Alt+/         # Toggle tiles (horizontal/vertical)
Alt+,         # Toggle accordion (horizontal/vertical)
Alt+Shift+F   # Fullscreen (temporary)
```

#### 6. Resize Mode (The Better Way)

**Basic resize:**
```toml
Alt+Shift+-    # Shrink by 50px
Alt+Shift+=    # Grow by 50px
```

**Advanced: Resize Mode**
```toml
Alt+R          # Enter resize mode

# In resize mode:
h              # Shrink width (-50px)
l              # Grow width (+50px)
k              # Shrink height (-50px)
j              # Grow height (+50px)

Shift+h        # Fine shrink width (-10px)
Shift+l        # Fine grow width (+10px)
Shift+k        # Fine shrink height (-10px)
Shift+j        # Fine grow height (+10px)

b              # Balance all windows (equal sizes)
<Esc>          # Exit resize mode
```

**Why modal resize?**
- No holding modifier keys (easier on fingers)
- Rapid adjustments (press j j j j for +200px)
- Fine control with Shift (pixel-perfect)
- Natural vim muscle memory

#### 7. Service Mode (Advanced Operations)

**Service mode = power user features:**
```toml
Alt+Space      # Enter service mode

# Layout operations:
f              # Toggle floating/tiling
b              # Balance all window sizes
-              # Flatten workspace tree (reset layout)
<Backspace>    # Close all windows except current

# Join operations (create containers):
h              # Join with left neighbor
j              # Join with down neighbor
k              # Join with up neighbor
l              # Join with right neighbor

<Esc>          # Exit service mode
```

**What is "join"?**

Join creates container groupings:

```
Before:
[A][B][C]

Alt+Space, l (while focused on A):

After:
[A,B][C]  ← A and B now in a container
```

**Use case:** Group related windows (editor + terminal) to move/resize together.

#### 8. Monitor Management

**Multi-monitor setup:**
```toml
Alt+P              # Focus previous monitor
Alt+N              # Focus next monitor
Alt+Shift+P        # Move window to previous monitor
Alt+Shift+N        # Move window to next monitor
Alt+Shift+Tab      # Move entire workspace to next monitor
```

**Mouse follows focus:**
```toml
# aerospace/.config/aerospace/aerospace.toml:58-61
on-focused-monitor-changed = ['move-mouse monitor-lazy-center']
on-focus-changed = "move-mouse window-lazy-center"
```

Your cursor automatically moves to the focused window/monitor. No hunting for the cursor!

#### 9. Gaps & Aesthetics

**Floating aesthetic:**
```toml
# aerospace/.config/aerospace/aerospace.toml:67-73
[gaps]
inner.horizontal = 10     # Space between windows
inner.vertical = 10
outer.left = 10           # Space from screen edges
outer.bottom = 30         # Dramatic floating effect
outer.top = 30            # Room for status bar
outer.right = 10
```

**Why large bottom gap?**
- Symmetrical with sides (10px)
- Gives "floating above desktop" aesthetic
- Prevents windows from touching dock area
- Matches Tokyo Night dramatic style

#### 10. Borders Integration

**JankyBorders for visual feedback:**
```toml
# aerospace/.config/aerospace/aerospace.toml:14-16
after-startup-command = [
  'exec-and-forget /opt/homebrew/bin/borders active_color=0xff7aa2f7 inactive_color=0xff565f89 width=6.0 style=round'
]
```

**What this does:**
- Active window: Blue border (#7aa2f7 - Tokyo Night blue)
- Inactive windows: Gray border (#565f89 - Tokyo Night comment)
- 6px width, rounded corners
- Always know which window has focus

#### 11. Workspace Mode (Power Navigation)

**Workspace mode = rapid workspace management:**
```toml
Alt+W          # Enter workspace mode

# Navigate:
h              # Previous workspace
l              # Next workspace
j              # Next monitor
k              # Previous monitor

# Direct access:
b              # Go to Browser workspace
t              # Go to Terminal workspace
d              # Go to Development workspace
m              # Go to Media workspace
s              # Go to Slack workspace
e              # Go to Email workspace

# Move window and follow:
Shift+B        # Move window to Browser AND switch to it
Shift+T        # Move window to Terminal AND switch to it
# ... etc

<Esc>          # Exit workspace mode
```

**Use case:** Rapid context switching without reaching for multiple modifier keys.

#### 12. Normalization (Tree Optimization)

**What is normalization?**

AeroSpace automatically optimizes window tree structure to prevent weird layouts.

```toml
# aerospace/.config/aerospace/aerospace.toml:32-34
enable-normalization-flatten-containers = true
enable-normalization-opposite-orientation-for-nested-containers = true
```

**Example of flatten-containers:**
```
Before:
Container
  └── Container (unnecessary nesting)
      └── Window A

After normalization:
Container
  └── Window A
```

**Example of opposite-orientation:**
```
Before:
Horizontal Container
  └── Horizontal Container (same orientation, weird)
      ├── Window A
      └── Window B

After normalization:
Horizontal Container
  ├── Window A
  └── Window B
```

This prevents layouts from getting tangled.

---

## LazyVim: The Neovim Distribution

LazyVim is a Neovim configuration framework built on top of lazy.nvim plugin manager. It provides a complete IDE experience out of the box.

### Why LazyVim?

**vs Raw Neovim:**
- Raw Neovim: Start from scratch, configure everything
- LazyVim: Sane defaults, 100+ plugins pre-configured

**vs LunarVim:**
- LunarVim: Opinionated, harder to customize
- LazyVim: Modular, easy to extend/override

**vs AstroNvim:**
- AstroNvim: Full-featured, steeper learning curve
- LazyVim: Simpler structure, better documentation

**vs NvChad:**
- NvChad: Beautiful UI-focused
- LazyVim: Productivity-focused, sensible defaults

### Core Concepts

#### 1. Lazy.nvim Plugin Manager

**Traditional plugin managers (Packer, Vim-Plug):**
```lua
-- Load all plugins at startup
require('packer').startup(function()
  use 'plugin1'
  use 'plugin2'
  -- ... 50 more plugins
  -- Startup: 500ms+
end)
```

**Lazy.nvim approach:**
```lua
-- Load plugins only when needed
require("lazy").setup({
  spec = {
    { "LazyVim/LazyVim", import = "lazyvim.plugins" },
    { import = "plugins" },  -- Your custom plugins
  },
  defaults = {
    lazy = false,  -- Your plugins load at startup
    version = false,  -- Always use latest git commit
  },
})
```

**Lazy loading strategies:**
- `event = "VeryLazy"` - Load after startup
- `ft = "python"` - Load only for Python files
- `cmd = "Telescope"` - Load when command is used
- `keys = "<leader>f"` - Load when key is pressed

**Result:** Neovim starts in 30-50ms, plugins load as needed.

#### 2. LazyVim Structure

**Your Neovim config layout:**
```
nvim/.config/nvim/
├── init.lua                    # Entry point (bootstraps lazy.nvim)
└── lua/
    ├── config/
    │   ├── lazy.lua            # Plugin manager setup
    │   ├── keymaps.lua         # Custom keybindings
    │   ├── options.lua         # Vim options
    │   └── autocmds.lua        # Autocommands
    └── plugins/
        ├── tokyonight.lua      # Theme configuration
        ├── dashboard.lua       # Start screen
        └── example.lua         # Custom plugins
```

**Loading order:**
1. `init.lua` bootstraps lazy.nvim
2. `config/lazy.lua` sets up plugin manager
3. LazyVim default plugins load
4. Your `plugins/*.lua` files load (override defaults)
5. `config/options.lua` applies settings
6. `config/keymaps.lua` sets keybindings
7. `config/autocmds.lua` registers autocommands

#### 3. Tokyo Night Integration

**Exact theme matching across environment:**
```lua
-- nvim/.config/nvim/lua/plugins/tokyonight.lua:10-26
opts = {
  style = "night",              -- Same as WezTerm
  terminal_colors = true,       -- Match terminal

  on_colors = function(colors)
    -- Exact hex codes from SketchyBar
    colors.bg = "#1a1b26"       -- Background
    colors.fg = "#c0caf5"       -- Foreground
    colors.blue = "#7aa2f7"     -- Commands, functions
    colors.green = "#9ece6a"    -- Strings, success
    colors.red = "#f7768e"      -- Errors, deletions
    colors.cyan = "#7dcfff"     -- Constants, info
    colors.magenta = "#bb9af7"  -- Keywords, types
  end,
}
```

**Visual consistency:**
- Shell syntax highlighting: blue commands
- Neovim functions: blue
- Shell strings: green
- Neovim strings: green
- AeroSpace borders: blue (active), gray (inactive)
- Neovim cursor line: blue accent

Same colors = less cognitive load = faster context switching.

#### 4. LazyVim Default Keybindings

**Leader key: Space**

LazyVim uses `<Space>` as the leader, conflicting with vim's default. But it's the most accessible key on the keyboard.

**Essential keybindings:**

**File navigation:**
```vim
<leader>ff    " Find files (Telescope)
<leader>fr    " Recent files
<leader>fg    " Grep in files (ripgrep)
<leader>fb    " Find buffers
<leader>e     " File explorer (Neo-tree)
```

**Code navigation:**
```vim
gd            " Go to definition
gr            " Go to references
K             " Hover documentation
<leader>ca    " Code action
<leader>cr    " Rename symbol
```

**Window management:**
```vim
<C-h>         " Focus window left
<C-j>         " Focus window down
<C-k>         " Focus window up
<C-l>         " Focus window right
<leader>w     " Save file
<leader>q     " Quit
```

**Terminal:**
```vim
<C-/>         " Toggle terminal
<C-_>         " Toggle terminal (alternative)
```

**Git (via Lazygit):**
```vim
<leader>gg    " Lazygit
<leader>gb    " Git blame line
```

**Search & Replace:**
```vim
<leader>sr    " Search and replace
<leader>ss    " Search in file
/             " Forward search
?             " Backward search
```

#### 5. LSP (Language Server Protocol)

**What is LSP?**

Language servers provide IDE features:
- Autocomplete
- Go to definition
- Find references
- Rename refactoring
- Diagnostics (errors/warnings)
- Hover documentation

**LazyVim LSP setup:**
```lua
-- Automatically installs language servers
-- Via mason.nvim
```

**Common language servers:**
- `typescript-language-server` - TypeScript/JavaScript
- `pyright` - Python
- `rust-analyzer` - Rust
- `gopls` - Go
- `lua-language-server` - Lua

**LSP keybindings:**
```vim
gd            " Go to definition (jump to where function is defined)
gr            " Go to references (find all usages)
gi            " Go to implementation
K             " Hover documentation (show function signature)
<leader>ca    " Code actions (quick fixes, refactorings)
<leader>cr    " Rename symbol (refactor across project)
[d            " Previous diagnostic (go to previous error)
]d            " Next diagnostic (go to next error)
<leader>cd    " Show diagnostics (list all errors)
```

**Example workflow:**
```vim
" 1. See red underline on function call
" 2. Press K to see error message
" 3. Press <leader>ca to see quick fixes
" 4. Select fix, applied automatically
```

#### 6. Telescope (Fuzzy Finder)

**Telescope = fzf for Neovim**

```vim
<leader>ff    " Find files
<leader>fg    " Live grep (search in files)
<leader>fb    " Find buffers (open files)
<leader>fh    " Find help tags
<leader>fr    " Recent files
<leader>fc    " Find commands
<leader>fk    " Find keymaps
```

**Telescope UI:**
```
┌─ Find Files ────────────────────┐
│ > config                        │  ← Search query
├─────────────────────────────────┤
│ ▶ config/options.lua            │  ← Results
│   config/keymaps.lua            │
│   config/lazy.lua               │
├─────────────────────────────────┤
│ Preview:                        │
│ 1 -- Options are automatically  │
│ 2 -- loaded before lazy.nvim    │
│ 3 -- startup                    │
└─────────────────────────────────┘
```

**Telescope keybindings (in picker):**
```vim
<C-n>         " Next result
<C-p>         " Previous result
<C-j>         " Next result (alt)
<C-k>         " Previous result (alt)
<CR>          " Open selected
<C-x>         " Open in horizontal split
<C-v>         " Open in vertical split
<C-t>         " Open in new tab
<C-u>         " Scroll preview up
<C-d>         " Scroll preview down
<Esc>         " Close picker
```

#### 7. Neo-tree (File Explorer)

**Neo-tree = visual file tree**

```vim
<leader>e     " Toggle Neo-tree
<leader>E     " Toggle Neo-tree (alt)
```

**Neo-tree navigation:**
```vim
j/k           " Move down/up
h             " Collapse folder or go to parent
l             " Expand folder or open file
<CR>          " Open file
<Space>       " Preview file
a             " Add file/folder
d             " Delete
r             " Rename
c             " Copy
x             " Cut
p             " Paste
R             " Refresh
H             " Toggle hidden files
```

**Neo-tree layout:**
```
╭─ Neo-tree ─────────╮
│ 📁 dotfiles        │
│   📂 nvim          │
│     📂 lua         │
│       📂 config    │
│         📄 lazy.lua│ ← Selected
│       📂 plugins   │
│   📂 wezterm       │
│   📂 zsh           │
╰────────────────────╯
```

#### 8. Which-Key (Keybinding Helper)

**Which-key = discoverability**

Press `<leader>` and wait 300ms → popup shows all available keybindings.

```
╭─ Leader Keybindings ─────────────╮
│ f  +file                         │
│ s  +search                       │
│ c  +code                         │
│ g  +git                          │
│ w  save file                     │
│ q  quit                          │
│ e  file explorer                 │
╰──────────────────────────────────╯
```

Press `f` → shows file operations:
```
╭─ File Operations ────────────────╮
│ f  find files                    │
│ r  recent files                  │
│ g  grep files                    │
│ b  find buffers                  │
╰──────────────────────────────────╯
```

**No need to memorize everything!** Just press leader and explore.

#### 9. Autocomplete (nvim-cmp)

**nvim-cmp = intelligent autocomplete**

**Sources:**
- LSP (language server suggestions)
- Buffer (words from current file)
- Path (filesystem paths)
- Snippets (code templates)

**Completion UI:**
```
local function my_func()
  pri█
  ┌─────────────────────────────┐
  │ ▶ print()          [LSP]   │
  │   private          [Keyword]│
  │   printf()         [LSP]   │
  └─────────────────────────────┘
```

**Completion keybindings:**
```vim
<C-n>         " Next suggestion
<C-p>         " Previous suggestion
<C-y>         " Accept suggestion
<C-e>         " Close completion
<Tab>         " Next suggestion (alt)
<S-Tab>       " Previous suggestion (alt)
<CR>          " Accept suggestion (Enter)
```

**Snippet expansion:**
```vim
" Type: fn<Tab>
function name(params)
  █
end

" Cursor at █, ready to type function body
" Tab jumps between placeholders
```

#### 10. LazyVim Extras

**LazyVim extras = optional feature sets**

```vim
:LazyExtras    " Browse available extras
```

**Useful extras:**
- `lang.typescript` - TypeScript support
- `lang.python` - Python support
- `lang.rust` - Rust support
- `lang.go` - Go support
- `editor.mini-ai` - Enhanced text objects
- `ui.edgy` - Better window management
- `coding.copilot` - GitHub Copilot integration

**Enable extras:**
```lua
-- nvim/.config/nvim/lua/config/lazy.lua
spec = {
  { "LazyVim/LazyVim", import = "lazyvim.plugins" },
  { import = "lazyvim.plugins.extras.lang.typescript" },
  { import = "lazyvim.plugins.extras.coding.copilot" },
  { import = "plugins" },
}
```

#### 11. Customizing LazyVim

**Adding plugins:**
```lua
-- nvim/.config/nvim/lua/plugins/my-plugin.lua
return {
  {
    "plugin/repo",
    event = "VeryLazy",  -- When to load
    config = function()
      require("plugin").setup({
        -- Plugin configuration
      })
    end,
  }
}
```

**Overriding keybindings:**
```lua
-- nvim/.config/nvim/lua/config/keymaps.lua
local map = vim.keymap.set

-- Custom keybinding
map("n", "<leader>x", "<cmd>!chmod +x %<CR>", { desc = "Make executable" })

-- Override default
map("n", "<leader>w", "<cmd>w!<CR>", { desc = "Force save" })
```

**Changing options:**
```lua
-- nvim/.config/nvim/lua/config/options.lua
vim.opt.relativenumber = false  -- Disable relative line numbers
vim.opt.wrap = true            -- Enable line wrapping
vim.opt.colorcolumn = "80"     -- Show column guide
```

---

## Integration & Workflows

How these three tools work together to create a unified environment.

### Workflow 1: Full-Stack Development

**Setup:**
```
Monitor 1 - Development (Alt+D):
  ├── Neovim (full screen editing)

Monitor 1 - Terminal (Alt+T):
  ├── Top: npm run dev (backend)
  ├── Bottom-left: npm run dev (frontend)
  └── Bottom-right: logs tail

Monitor 2 - Browser (Alt+B):
  ├── Left: Localhost (app)
  └── Right: Documentation
```

**Creating the layout:**
```bash
# 1. Terminal workspace
Alt+T                    # Switch to Terminal
Ctrl+G t                 # New tab
Ctrl+G r                 # Rename to "API"
z api && npm run dev     # Start backend

Ctrl+G s                 # Split vertically (below)
z frontend && npm run dev # Start frontend

Ctrl+G k                 # Focus up to backend pane
Ctrl+G v                 # Split horizontally (right)
tail -f logs/app.log     # Monitor logs

# 2. Editor workspace
Alt+D                    # Switch to Development
z api && v .            # Open backend code

# 3. Browser workspace
Alt+B                    # Switch to Browser
# Open browser to localhost:3000
Alt+l                    # Focus right window
# Open docs
```

**Navigating the workflow:**
```bash
# Edit code
Alt+D                    # Focus editor
# Make changes in Neovim
:w                       # Save (LazyVim auto-formats)

# Check terminal output
Alt+T                    # Focus terminal
# See logs in real-time

# Refresh browser
Alt+B                    # Focus browser
Cmd+R                    # Refresh (browser shortcut)

# Back to editing
Alt+D                    # Back to editor
```

### Workflow 2: Learning & Exploration

**Setup:**
```
Single Monitor:
  ├── Left: Browser (tutorial)
  └── Right: WezTerm
      ├── Top: Neovim (notes)
      └── Bottom: Shell (experiments)
```

**Creating the layout:**
```bash
# 1. Split screen with browser and terminal
Alt+B                    # Browser workspace
# Open tutorial
Alt+/                    # Toggle horizontal layout
Alt+T                    # Switch to Terminal
Alt+Shift+B              # Move terminal to Browser workspace
Alt+l                    # Focus browser (left side)

# 2. Split terminal into editor + shell
Ctrl+G s                 # Split vertically
# Top pane: Neovim for notes
v notes.md
# Bottom pane: Shell for experiments
```

**Learning flow:**
```bash
# Read tutorial
Alt+h                    # Focus browser

# Take notes
Alt+l                    # Focus terminal (right side)
Ctrl+G k                 # Focus top pane (Neovim)
# Type notes in Markdown

# Try commands
Ctrl+G j                 # Focus bottom pane (shell)
# Run examples from tutorial

# Repeat
Alt+h                    # Back to browser for next section
```

### Workflow 3: Code Review

**Setup:**
```
Development Workspace (Alt+D):
  ├── Left: Original file
  └── Right: Modified file
```

**Creating the layout:**
```bash
# 1. Open original file
Alt+D
v src/original.ts

# 2. Split and open modified version
:vsplit src/modified.ts

# Or use Neovim diff mode:
:wincmd v                # Vertical split
:e src/modified.ts       # Open file
:windo diffthis          # Enable diff in both windows
```

**Navigating diff:**
```vim
]c            " Next change
[c            " Previous change
do            " Diff obtain (get change from other window)
dp            " Diff put (send change to other window)
:diffoff      " Disable diff mode
```

### Workflow 4: System Monitoring

**Setup:**
```
Media Workspace (Alt+M):
  ├── Top-left: htop (system monitor)
  ├── Top-right: docker stats
  ├── Bottom-left: tail -f app.log
  └── Bottom-right: watch kubectl get pods
```

**Creating the layout:**
```bash
Alt+M                    # Media workspace (or any workspace)
Ctrl+G s                 # Split below
Ctrl+G v                 # Split right (top pane)
htop                     # System monitor

Ctrl+G l                 # Focus right
docker stats             # Container stats

Ctrl+G j                 # Focus bottom-left
tail -f app.log          # Application logs

Ctrl+G l                 # Focus bottom-right
watch kubectl get pods   # Kubernetes status

# All running simultaneously, full view
```

**Monitoring flow:**
```bash
# Check system resources
Ctrl+G h                 # Focus htop
# See CPU/memory

# Check containers
Ctrl+G l                 # Focus docker stats
# See container usage

# Check application logs
Ctrl+G j                 # Focus app logs
# See recent activity

# Check Kubernetes
Ctrl+G l                 # Focus kubectl
# See pod status
```

### Integration Patterns

**Pattern 1: Context Switching**
```bash
# Work context → Personal context
Alt+D                    # Development workspace (work)
Alt+E                    # Email workspace (personal)
# Instant switch, no window hunting
```

**Pattern 2: Window Following**
```bash
# Move work to external monitor
Alt+Shift+N              # Move workspace to next monitor
# Windows, tabs, everything moves together
```

**Pattern 3: Quick Terminal from Editor**
```vim
" In Neovim
<C-/>                    " Toggle terminal below
" Run quick command
<C-/>                    " Hide terminal
" Back to editing, no context lost
```

**Pattern 4: Session Persistence**
```bash
# End of day
Ctrl+G d                 # Detach from domain
# Close laptop

# Next morning
# Open WezTerm
# Automatically reconnects to domain
# All tabs, splits, exactly as left
```

---

## Advanced Tips

### WezTerm

**1. Custom launch menu:**
```lua
-- Add to wezterm.lua
config.launch_menu = {
  { label = "Python REPL", args = { "python3" } },
  { label = "Node REPL", args = { "node" } },
  { label = "SSH Server", args = { "ssh", "user@server" } },
}
-- Access with: Ctrl+G p
```

**2. Conditional config:**
```lua
-- Different settings for work vs personal
if hostname == "work-laptop" then
  config.font_size = 14
else
  config.font_size = 22
end
```

### AeroSpace

**1. App-specific workspace routing (disabled by default):**
```toml
# [workspace-to-monitor-force-assignment]
# B = 'secondary'  # Force Browser workspace to secondary monitor
```

**2. Floating exceptions:**
```toml
# Some apps should never tile
[[on-window-detected]]
if.app-id = 'com.apple.systempreferences'
run = ['layout floating']
```

**3. Quick balance all:**
```bash
# After opening many windows
Alt+Space b              # Service mode → balance sizes
# Instant perfect layout
```

### LazyVim

**1. Project-specific config:**
```lua
-- .nvim.lua in project root
vim.opt.shiftwidth = 2   -- 2-space indents for this project
vim.opt.colorcolumn = "120"  -- Longer line length
```

**2. Custom snippets:**
```lua
-- Add to plugins/luasnip.lua
local ls = require("luasnip")
ls.add_snippets("javascript", {
  ls.parser.parse_snippet("cl", "console.log($1)"),
})
-- Type: cl<Tab> → console.log()
```

**3. Workspace-specific sessions:**
```vim
:Telescope projects      " Browse projects
" Select project → auto-restores tabs, buffers
```

---

## Troubleshooting

### WezTerm

**Domain not connecting:**
```bash
# Check if domain socket exists
ls ~/.local/share/wezterm/

# Manually connect
wezterm connect unix

# Force new domain
rm ~/.local/share/wezterm/unix-*
# Restart WezTerm
```

**Font icons not showing:**
```bash
# Install Nerd Font
brew install --cask font-jetbrains-mono-nerd-font

# Verify in WezTerm
echo "   "  # Should show icons
```

### AeroSpace

**Windows not tiling:**
```bash
# Check if AeroSpace is running
ps aux | grep aerospace

# Reload config
Alt+Space → Esc

# Check logs
tail -f ~/.aerospace/aerospace.log
```

**Borders not showing:**
```bash
# Restart borders
pkill borders
borders active_color=0xff7aa2f7 inactive_color=0xff565f89 width=6.0 style=round
```

### LazyVim

**LSP not working:**
```vim
:LspInfo                 " Check LSP status
:Mason                   " Install missing language servers
:Lazy sync               " Update plugins
```

**Slow startup:**
```vim
:Lazy profile            " See plugin load times
" Disable slow plugins or make them lazy-load
```

**Keybinding not working:**
```vim
:verbose map <leader>f   " See what's mapped to leader-f
:Telescope keymaps       " Browse all keybindings
```

---

## Further Resources

**WezTerm:**
- [Official Docs](https://wezfurlong.org/wezterm/)
- [Configuration Examples](https://github.com/wez/wezterm/discussions)

**AeroSpace:**
- [GitHub Repo](https://github.com/nikitabobko/AeroSpace)
- [Configuration Guide](https://nikitabobko.github.io/AeroSpace/guide)

**LazyVim:**
- [Official Docs](https://www.lazyvim.org/)
- [Default Keybindings](https://www.lazyvim.org/keymaps)
- [Plugin List](https://www.lazyvim.org/plugins)

---

**You now have a complete understanding of your development environment.** Each tool is powerful alone, but together they create a seamless, keyboard-driven workflow that eliminates context switching and maximizes productivity.

Practice the workflows, customize to your needs, and enjoy your new superpower! 🚀
