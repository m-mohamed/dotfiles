# Essential Keymaps Cheat Sheet

**Last Updated:** 2025-01-09 (comprehensive LazyVim + Claude Code update)

Your complete guide to WezTerm, Neovim/LazyVim (58 plugins), Claude Code AI, and Aerospace.

---

## Quick Reference

### Most Used (Commit to Muscle Memory)
```
WezTerm:     Ctrl+a → s/v/h/j/k/l/q/z/t/[/]
Neovim:      Space Space / gd / gr / K / Space ca / Shift+H/L
Claude AI:   Space ac / Space ab / Space as / Space aa/ad
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
| `Ctrl+a` → `Shift+R` | Rename workspace | Prompt for new workspace name |
| `Ctrl+a` → `p` | Show launcher | General launcher menu |
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

### Setup Overview
- **Distribution**: LazyVim (VS Code-like IDE with vim keybindings)
- **Version**: Neovim 0.11.4
- **Plugins**: 58 installed (lazy.nvim plugin manager)
- **Completion**: Blink.cmp (Rust-based, blazing fast)
- **Theme**: Tokyo Night (night variant)
- **AI**: Claude Code + GitHub Copilot + Blink Copilot
- **Philosophy**: Minimal custom config, trust LazyVim defaults

### Leader Key
**`Space`** (default LazyVim)

### Important Note: Disabled Keybindings
**Alt+j/k** line movement has been disabled to prevent conflicts with Aerospace window navigation.
**Alternatives:** Use `]e` / `[e` for line movement, or visual mode + `:m` commands.

### 🔥 Top 20 ESSENTIAL Keymaps (Absolute Priority)

| Keymap | Action | Usage |
|--------|--------|-------|
| **File Navigation** |||
| `Space Space` | Find files (fuzzy) | **PRIMARY** file navigation |
| `Space /` | Grep in project | Search text across all files |
| `Space ,` or `Space fb` | Buffer list | Switch between open files |
| `Shift+H` / `Shift+L` | Prev/Next buffer | Quick buffer switching |
| `Space bd` | Close buffer | Close current file |
| **Code Navigation** |||
| `gd` | Go to definition | Jump to where symbol is defined |
| `gr` | Find references | Show all usages of symbol |
| `gI` | Go to implementation | Jump to implementation |
| `K` | Hover docs | Show documentation popup |
| `Ctrl+h/j/k/l` | Navigate splits | Move between editor windows |
| **Code Actions** |||
| `Space ca` | Code action | ⭐ Quick fixes, imports, refactoring |
| `Space cr` | Rename symbol | LSP rename (updates all references) |
| `Space cf` | Format code | Auto-format current file |
| `]d` / `[d` | Next/Prev diagnostic | Navigate errors/warnings |
| `Space cd` | Line diagnostics | Show error details popup |
| **Editing** |||
| `Space -` / `Space \|` | Split below/right | Create splits |
| `Space wd` | Delete window | Close current split |
| `:w` | Save file | Classic vim save |
| `gcc` | Comment line | Toggle comment (normal mode) |
| `gc` + motion | Comment motion | e.g., `gcap` = comment paragraph |

### File & Project Navigation

| Keymap | Action |
|--------|--------|
| `Space Space` | Find files (fuzzy finder) |
| `Space ff` | Find files (same as above) |
| `Space fr` | Recent files |
| `Space fg` | Find git files |
| `Space ,` | Switch buffers |
| `Space fb` | Buffer list |
| `Space /` | Grep in project |
| `Space :` | Command history |

### Window/Split Management

| Keymap | Action |
|--------|--------|
| `Ctrl+h/j/k/l` | Navigate splits (vim-style) |
| `Ctrl+w s` | Split horizontal |
| `Ctrl+w v` | Split vertical |
| `Ctrl+w q` | Close split |
| `Ctrl+w o` | Close all other splits |
| `Space -` | Split below |
| `Space \|` | Split right |
| `Space wd` | Delete window |

### Buffer Management

| Keymap | Action |
|--------|--------|
| `Shift+H` | Previous buffer |
| `Shift+L` | Next buffer |
| `Space bd` | Delete buffer |
| `Space bp` | Pin buffer |
| `Space bP` | Delete non-pinned buffers |
| `Space ,` | Switch buffers (Telescope) |

### LSP Code Actions (Language Server Protocol)

| Keymap | Action |
|--------|--------|
| `gd` | Go to definition |
| `gr` | Find references |
| `gI` | Go to implementation |
| `gy` | Go to type definition |
| `gD` | Go to declaration |
| `K` | Hover documentation |
| `Space ca` | Code action ⭐ |
| `Space cr` | Rename symbol |
| `Space cf` | Format document |
| `Space cF` | Format injected (markdown code blocks) |
| `Space cd` | Line diagnostics |
| `Space cl` | LSP info |
| `]d` / `[d` | Next/Prev diagnostic |
| `]e` / `[e` | Next/Prev error |
| `]w` / `[w` | Next/Prev warning |

### Search & Replace

| Keymap | Action |
|--------|--------|
| `Space /` | Grep (root dir) |
| `Space sg` | Grep (root dir) |
| `Space sG` | Grep (cwd) |
| `Space sw` | Grep word under cursor |
| `Space sr` | Search & replace (grug-far) |

### Git Integration

| Keymap | Action |
|--------|--------|
| `Space gg` | Lazygit (if installed) |
| `Space gb` | Git blame line |
| `Space gB` | Git browse (GitHub) |
| `]h` / `[h` | Next/Prev git hunk |
| `Space ghs` | Stage hunk |
| `Space ghu` | Unstage hunk |
| `Space ghp` | Preview hunk |
| `Space ghr` | Reset hunk |

### UI Toggles

| Keymap | Action |
|--------|--------|
| `Space uf` | Toggle auto-format |
| `Space ud` | Toggle diagnostics |
| `Space ul` | Toggle line numbers |
| `Space uL` | Toggle relative line numbers |
| `Space uw` | Toggle word wrap |
| `Space uz` | Toggle zen mode |
| `Space uc` | Toggle conceal |
| `Space uh` | Toggle inlay hints |

### Telescope (Fuzzy Finder)

| Keymap | Action |
|--------|--------|
| `Space Space` | Find files |
| `Space /` | Live grep |
| `Space fb` | Buffers |
| `Space fr` | Recent files |
| `Space fc` | Find config files |
| `Space fC` | Find LazyVim config |
| `Space gc` | Git commits |
| `Space gs` | Git status |
| `Space sa` | Auto commands |
| `Space sb` | Buffer search |
| `Space sc` | Commands |
| `Space sC` | Command history |
| `Space sd` | Document diagnostics |
| `Space sD` | Workspace diagnostics |
| `Space sh` | Help pages |
| `Space sk` | Keymaps (search all keybindings!) |
| `Space sm` | Marks |
| `Space sM` | Man pages |
| `Space so` | Options |
| `Space sR` | Resume Telescope |
| `Space ss` | Goto symbol |
| `Space sS` | Goto symbol (workspace) |

### Terminal

| Keymap | Action |
|--------|--------|
| `Space ft` | Terminal (root dir) |
| `Space fT` | Terminal (cwd) |
| `Ctrl+\` | Terminal (toggle) |
| `Ctrl+/` | Terminal (floating) |
| `Esc Esc` | Exit terminal mode |

### Debugging (DAP - Debug Adapter Protocol)

| Keymap | Action |
|--------|--------|
| `Space db` | Toggle breakpoint |
| `Space dB` | Breakpoint condition |
| `Space dc` | Continue |
| `Space dC` | Run to cursor |
| `Space dg` | Go to line (no execute) |
| `Space di` | Step into |
| `Space dj` | Down |
| `Space dk` | Up |
| `Space dl` | Run last |
| `Space do` | Step out |
| `Space dO` | Step over |
| `Space dp` | Pause |
| `Space dr` | Toggle REPL |
| `Space ds` | Session |
| `Space dt` | Terminate |
| `Space dw` | Widgets |

### Testing (Neotest)

| Keymap | Action |
|--------|--------|
| `Space tt` | Run nearest test |
| `Space tT` | Run all tests |
| `Space tf` | Run test file |
| `Space ts` | Toggle test summary |
| `Space to` | Toggle test output |
| `Space tO` | Toggle test output panel |
| `Space tw` | Toggle test watch |

### Flash (Enhanced Navigation)

| Keymap | Action |
|--------|--------|
| `s` | Flash (jump to any location with 2 chars) |
| `S` | Flash treesitter |
| `r` | Remote flash (operator-pending) |
| `R` | Treesitter search |

### Yanky (Yank History)

| Keymap | Action |
|--------|--------|
| `y` | Yank text |
| `p` | Paste after |
| `P` | Paste before |
| `gp` | Paste after and leave cursor |
| `gP` | Paste before and leave cursor |
| `]p` | Cycle forward through yank history |
| `[p` | Cycle backward through yank history |
| `Space p` | Open yank history (Telescope) |

### Todo Comments

| Keymap | Action |
|--------|--------|
| `]t` | Next todo comment |
| `[t` | Previous todo comment |
| `Space st` | Todo (Telescope) |
| `Space sT` | Todo/Fix/Fixme (Telescope) |
| `Space xt` | Todo (Trouble) |
| `Space xT` | Todo/Fix/Fixme (Trouble) |

### Trouble (Diagnostics)

| Keymap | Action |
|--------|--------|
| `Space xx` | Toggle Trouble |
| `Space xX` | Toggle Trouble (buffer) |
| `Space xL` | Toggle Trouble (loclist) |
| `Space xQ` | Toggle Trouble (quickfix) |
| `[q` | Previous trouble item |
| `]q` | Next trouble item |

### Treesitter Text Objects (Advanced)

| Keymap | Action |
|--------|--------|
| `daf` | Delete around function |
| `dif` | Delete inside function |
| `dac` | Delete around class |
| `dic` | Delete inside class |
| `vif` | Visual select inside function |
| `vac` | Visual select around class |

### Which-Key Discovery
**Press `Space` and wait 1 second** → Shows all available keymaps in popup!
- `Space c` → All **code** actions
- `Space s` → All **search** actions
- `Space g` → All **git** actions
- `Space u` → All **UI toggles**
- `Space sk` → Search all keymaps in Telescope

### Configuration Notes

- **LazyVim distribution**: Battle-tested defaults, well-documented
- **Minimal custom config**: 3 files (~100 lines total)
- **Tokyo Night theme**: Matches WezTerm and Aerospace
- **58 plugins installed**: See "Installed Plugins" section below
- **Plugin manager**: lazy.nvim (auto-updates, lazy-loading)

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

## 4. Claude Code AI Integration

### What is Claude Code?
**Claude Code** (`claudecode.nvim`) - The first and only official-protocol-compatible Claude AI integration for Neovim. Implements the same WebSocket MCP (Model Context Protocol) as VS Code.

### How It Works
1. Creates WebSocket server on random port (10000-65535)
2. Writes lock file to `~/.claude/ide/[port].lock`
3. Claude CLI connects via WebSocket
4. **Bidirectional communication**:
   - Neovim → Claude: Current file, selections, diagnostics, workspace info
   - Claude → Neovim: Open files, show diffs, write code, execute commands

### Leader Key
**`Space a`** (AI/Claude Code prefix)

### Essential Claude Code Keymaps

| Keymap | Action | Usage |
|--------|--------|-------|
| `Space ac` | Toggle Claude terminal | Open/close Claude Code |
| `Space af` | Focus Claude terminal | Smart focus/toggle |
| `Space ar` | Resume Claude session | Resume last conversation |
| `Space aC` | Continue Claude | Continue from last message |
| `Space am` | Select model | Choose Sonnet/Opus/Haiku |
| `Space ab` | Add current buffer | Add file to Claude context |
| `Space as` | Send selection (visual) | Send visual selection to Claude |
| `Space as` | Add file (file tree) | In nvim-tree/neo-tree/oil/mini.files |
| `Space aa` | Accept diff | Accept Claude's proposed changes |
| `Space ad` | Deny diff | Reject Claude's proposed changes |

### Available Commands

```vim
:ClaudeCode                          " Toggle Claude terminal
:ClaudeCodeFocus                     " Smart focus/toggle
:ClaudeCodeSelectModel               " Choose model (Sonnet/Opus/Haiku)
:ClaudeCode --resume                 " Resume last session
:ClaudeCode --continue               " Continue from last message
:ClaudeCodeSend                      " Send visual selection
:ClaudeCodeAdd %                     " Add current file
:ClaudeCodeAdd /path/to/file 10 20   " Add file lines 10-20
:ClaudeCodeDiffAccept                " Accept Claude's changes
:ClaudeCodeDiffDeny                  " Reject Claude's changes
:ClaudeCodeStatus                    " Check connection status
```

### Claude Code Workflows

#### Workflow 1: Quick Question
```vim
1. Open file in Neovim
2. Space ac          → Opens Claude terminal
3. Type your question in Claude
4. Claude sees current file automatically
5. Claude responds (can open/edit files)
```

#### Workflow 2: Code Review/Refactor
```vim
1. Select code in visual mode (v/V)
2. Space as          → Sends selection to Claude
3. Ask Claude to review/refactor
4. Claude shows diff → Accept (Space aa) or Deny (Space ad)
5. Continue iteration
```

#### Workflow 3: Add Multiple Files to Context
```vim
1. Space ac          → Open Claude
2. In nvim-tree/neo-tree:
   - Navigate to file
   - Space as        → Add to context
   - Repeat for multiple files
3. Ask Claude about the codebase
```

#### Workflow 4: Debugging Session
```vim
1. Hit breakpoint in debugger
2. Space ab          → Add current buffer
3. Select stack trace (visual mode)
4. Space as          → Send to Claude
5. Ask "Why is this failing?"
6. Claude analyzes with full context
```

#### Workflow 5: Architecture Questions
```vim
1. Space ac          → Open Claude
2. Space ab          → Add current file
3. Ask: "How would you refactor this to use dependency injection?"
4. Claude suggests changes
5. Space aa          → Accept diff
```

### Diff Management

When Claude proposes changes:
- Opens **native Neovim diff** (side-by-side comparison)
- **Left**: Original file
- **Right**: Claude's proposed changes
- You can **edit Claude's version** before accepting
- **`:w`** or **`Space aa`** to accept
- **`:q`** or **`Space ad`** to reject

### Model Selection

Available models:
- **Claude Sonnet 3.5** (default) - Balanced speed/quality
- **Claude Opus 3** - Highest quality, slower
- **Claude Haiku 3** - Fastest, good for simple tasks

Use `Space am` or `:ClaudeCodeSelectModel` to switch.

### Troubleshooting Claude Code

```vim
:ClaudeCodeStatus                    " Check if connected
:messages                            " View plugin logs
```

**Common issues:**
- "Claude not connecting?" → Check `~/.claude/ide/` for lock files
- "Terminal not opening?" → Verify `claude` is in PATH: `which claude`
- Local installation? → Set `terminal_cmd = "~/.claude/local/claude"` in config

### Features

- ✅ **Pure Lua** - Zero external dependencies (uses `vim.loop`)
- ✅ **100% Protocol Compatible** - Same experience as VS Code
- ✅ **Real-time Context** - Claude sees your current file/selection automatically
- ✅ **Diff Management** - Native Neovim diff windows with accept/reject
- ✅ **Selection Tracking** - Sends visual selections to Claude (50ms delay)
- ✅ **File Tree Integration** - Works with nvim-tree, neo-tree, oil, mini.files
- ✅ **Snacks.nvim Integration** - Enhanced terminal with session persistence

---

## 5. Installed Plugins (58 Total)

### AI & Copilot (3 plugins)
- **`claudecode.nvim`** ⭐ - Claude Code integration (WebSocket MCP protocol)
- **`copilot.lua`** - GitHub Copilot inline suggestions
- **`blink-copilot`** - Copilot integration for blink.cmp completion

### Editor Enhancement (7 plugins)
- **`flash.nvim`** - Jump to any location with `s` + 2 characters
- **`mini.ai`** - Extended text objects (`daa`, `dib`, etc.)
- **`mini.pairs`** - Auto-close brackets, quotes
- **`mini.icons`** - Icon support (Nerd Font icons)
- **`mini.hipatterns`** - Highlight patterns (colors, TODOs)
- **`yanky.nvim`** - Improved yank/paste ring
- **`which-key.nvim`** - Shows available keybindings as you type

### LSP & Completion (7 plugins)
- **`nvim-lspconfig`** - LSP client configuration
- **`mason.nvim`** - LSP/DAP/linter/formatter installer
- **`mason-lspconfig.nvim`** - Bridges mason ↔ lspconfig
- **`blink.cmp`** - Blazing fast completion (Rust-based)
- **`lazydev.nvim`** - Lua LSP for Neovim config development
- **`SchemaStore.nvim`** - JSON schemas for autocomplete
- **`inc-rename.nvim`** - LSP rename with preview

### Treesitter (4 plugins)
- **`nvim-treesitter`** - Better syntax highlighting via parsing
- **`nvim-treesitter-textobjects`** - AST-based text objects
- **`nvim-ts-autotag`** - Auto-close HTML/JSX tags
- **`ts-comments.nvim`** - Context-aware commenting

### Git Integration (2 plugins)
- **`gitsigns.nvim`** - Git diff in gutter, blame, hunk navigation
- **`gh.nvim`** - GitHub CLI integration

### Search & Replace (2 plugins)
- **`grug-far.nvim`** - Project-wide search & replace UI
- **`telescope.nvim`** (via LazyVim) - Fuzzy finder

### UI & Notifications (9 plugins)
- **`noice.nvim`** - Beautiful UI for messages, cmdline, popups
- **`nui.nvim`** - UI component library
- **`lualine.nvim`** - Status line (bottom bar)
- **`bufferline.nvim`** - Buffer/tab line (top bar)
- **`snacks.nvim`** - Folke's utilities (terminal, dashboard, notifications)
- **`render-markdown.nvim`** - Live markdown preview in buffer
- **`dashboard.lua`** (custom) - Custom startup screen
- **`trouble.nvim`** - Beautiful diagnostics/quickfix/location list
- **`todo-comments.nvim`** - Highlight TODO, FIXME, HACK, etc.

### Debugging (7 plugins)
- **`nvim-dap`** - Debug adapter protocol client
- **`nvim-dap-ui`** - Debug UI (breakpoints, watches, stack traces)
- **`nvim-dap-virtual-text`** - Show variable values inline
- **`nvim-dap-python`** - Python debugging
- **`one-small-step-for-vimkind`** - Lua debugging
- **`mason-nvim-dap.nvim`** - DAP installer bridge
- **`litee.nvim`** - LSP symbol tree viewer

### Testing (2 plugins)
- **`neotest`** - Test runner framework
- **`neotest-python`** - Python test adapter (pytest, etc.)

### Formatting & Linting (2 plugins)
- **`conform.nvim`** - Formatter runner (prettier, black, stylua)
- **`nvim-lint`** - Linter runner (eslint, flake8)

### Python Development (1 plugin)
- **`venv-selector.nvim`** - Python virtual environment selector

### REST API Testing (1 plugin)
- **`kulala.nvim`** - HTTP client (like Postman, in Neovim)

### Database (3 plugins)
- **`vim-dadbod`** - Database client
- **`vim-dadbod-ui`** - UI for dadbod
- **`vim-dadbod-completion`** - SQL completion

### Markdown (1 plugin)
- **`markdown-preview.nvim`** - Preview markdown in browser

### Themes (2 plugins)
- **`tokyonight.nvim`** ⭐ - Active theme (Tokyo Night "night" variant)
- **`catppuccin`** - Alternative theme (installed but not active)

### Development Tools (2 plugins)
- **`dial.nvim`** - Enhanced increment/decrement (Ctrl+a/Ctrl+x)
- **`persistence.nvim`** - Session management (restore workspace)

### Libraries (3 plugins)
- **`plenary.nvim`** - Lua utilities (used by many plugins)
- **`nvim-nio`** - Async I/O library
- **`friendly-snippets`** - Snippet collection

### Core LazyVim (2 plugins)
- **`lazy.nvim`** - Plugin manager
- **`LazyVim`** - LazyVim distribution core

---

## 6. Living in Neovim Philosophy

### Overview: The Integrated Workflow

Your LazyVim setup is optimized for **staying in Neovim** for 95% of your development workflow. With Claude Code integration, snacks.nvim suite, and LazyGit, you can accomplish almost everything without leaving the editor.

**Core Principle:** Use Neovim as your **primary interface** for code, files, git, terminals, and AI assistance. Only switch to WezTerm for long-running background processes.

### When to Use Neovim vs WezTerm

#### ✅ Use Neovim Terminal (`Ctrl+/` or `Space ft`)

**Quick command execution:**
- Running tests (`npm test`, `pytest`)
- Git operations via LazyGit (`Space gg`)
- Build commands (`npm run build`)
- Quick file operations (`ls`, `mkdir`)
- Database queries (via `:DBUI`)
- API testing (via kulala.nvim)

**Advantages:**
- No context switch (stay in editor)
- Vim navigation in terminal history
- Window navigation with `Ctrl+h/j/k/l`
- Integrated with editor splits
- Session persistence

#### ✅ Use WezTerm

**Long-running processes:**
- Development servers (`npm run dev`, `python manage.py runserver`)
- Database servers
- Docker containers
- Log tailing
- File watchers

**Multiple independent tasks:**
- When you need 3+ simultaneous terminals
- Background monitoring while coding
- Tasks requiring full terminal features

**Best Practice:** Start servers in WezTerm, do everything else in Neovim.

---

## 7. File Navigation Mastery

### Your Three Navigation Methods

#### 1. Fuzzy Finder (PRIMARY - Fastest)

**When to use:**
- You know the file name (even partially)
- Quick access to specific files
- Large projects (500+ files)

**Keybindings:**
```
Space Space    - Find files (root dir) ⭐ PRIMARY
Space ff       - Same as above
Space fF       - Find files (cwd)
Space fg       - Find git files only
Space fr       - Recent files (MRU)
Space fR       - Recent files (cwd)
```

**Pro Tip:** `Space Space` is the **fastest way** to open files. Use it 80% of the time.

#### 2. File Explorer (VISUAL - Structure)

**When to use:**
- Exploring unfamiliar codebases
- Need to see directory structure
- File operations (rename, delete, move)
- Adding multiple files to Claude context
- Seeing git status visually

**Keybindings:**
```
Space e        - Toggle explorer (root) ⭐
Space E        - Toggle explorer (cwd)
```

**Within Explorer:**
```
NAVIGATION
l or Enter     - Open file / Toggle directory
h              - Close directory / Go to parent
H              - Toggle hidden files
I              - Toggle ignored files (gitignore)
Space /        - Grep in current directory

FILE OPERATIONS
a              - Add new file/directory
d              - Delete file/directory
m              - Move/rename
c              - Copy
y              - Yank (copy path)
p              - Paste

SELECTION
v / V          - Visual selection (multi-file)
Space as       - Add selected files to Claude context ⭐

PREVIEW & UTILITIES
P              - Toggle preview window
Ctrl+t         - Open terminal in directory
g?             - Show help
```

**Explorer Features:**
- **Git status indicators**: Modified, staged, untracked files shown with icons
- **LSP diagnostics**: Error/warning markers on files
- **Smart navigation**: Remembers cursor position
- **Quick grep**: `Space /` searches in current directory

#### 3. Recent Files (CONTEXT - Memory)

**When to use:**
- Jumping back to recently edited files
- Working on related files
- Returning to interrupted work

**Keybindings:**
```
Space fr       - Recent files list
Space fR       - Recent files (cwd only)
Shift+H/L      - Cycle through buffer history
```

### Decision Tree: Which Navigation Method?

```
START
  │
  ├─ Know exact file name? ────→ Space Space (fuzzy finder)
  │
  ├─ Recently worked on file? ──→ Space fr (recent files)
  │
  ├─ Need to see structure? ────→ Space e (file explorer)
  │
  ├─ Exploring codebase? ───────→ Space e + Claude Code
  │
  └─ Working in same files? ────→ Shift+H/L (buffer cycling)
```

---

## 8. File Explorer Deep Dive

### Opening the Explorer

```vim
Space e        " Toggle explorer (root directory)
Space E        " Toggle explorer (cwd)
```

**What you see:**
- Directory tree with icons
- Git status (green = staged, orange = modified, gray = untracked)
- LSP diagnostics (errors/warnings on files)
- Hidden files (toggled with `H`)

### Navigation Patterns

#### Basic Movement
```vim
j/k            " Move down/up
h              " Go to parent directory or close folder
l or Enter     " Open file or expand folder
gg / G         " Top/bottom of explorer
/              " Search (filter files by name)
```

#### Smart Navigation
```vim
]d / [d        " Next/prev diagnostic file
]g / [g        " Next/prev git modified file
Space /        " Grep in current directory
```

#### Directory Operations
```vim
h              " Go to parent (like cd ..)
<BS>           " Go up one level
~              " Go to home directory
.              " Change root to cursor directory
```

### File Operations

#### Creating Files/Folders
```vim
a              " Add new file/folder
               " Tip: End with / to create folder
               " Example: components/Button.tsx
               "          tests/           (folder)
```

#### Modifying Files
```vim
m              " Move/rename file
c              " Copy file
d              " Delete file (asks for confirmation)
y              " Yank (copy file path to clipboard)
p              " Paste copied/cut files
```

#### Multi-File Operations
```vim
v              " Start visual selection
V              " Select entire directory
Esc            " Clear selection
d              " Delete selected files
m              " Move selected files
Space as       " Add selected files to Claude context ⭐
```

### Integration with Claude Code

**Workflow: Exploring Codebase with Claude**

```vim
1. Space e           " Open explorer
2. Navigate to interesting directory
3. v (select file)   " Start visual selection
4. j/k (select more) " Select multiple files
5. Space as          " Add all to Claude context
6. Space ac          " Open Claude
7. "Explain the architecture of these files"
8. Claude analyzes all files together
```

**Pro Tip:** You can select an entire directory with `V`, then `Space as` to add all files in that folder to Claude's context.

### Git Integration in Explorer

**Visual Git Status:**
- ● Green icon = Staged
- ● Orange icon = Modified (unstaged)
- ● Gray icon = Untracked
- ✓ No icon = Committed

**Git Operations from Explorer:**
```vim
Space gg       " Open LazyGit (primary git workflow)
Space gb       " Git blame current file
]g / [g        " Jump to next/prev modified file
```

### Preview Window

```vim
P              " Toggle preview
               " Shows file contents without opening
               " Great for quick browsing
```

**Preview features:**
- Syntax highlighting
- Scrollable with j/k
- Updates as you navigate
- Closes with `P` or when opening file

### Explorer Workflow Patterns

#### Pattern 1: Quick File Creation
```vim
Space e        " Open explorer
a              " Add new file
components/Header.tsx  " Type path
Enter          " Create file
               " File opens automatically
```

#### Pattern 2: Refactoring/Reorganizing
```vim
Space e        " Open explorer
Navigate to file
m              " Move/rename
new/path/file.tsx      " Type new path
Enter          " Confirm
               " All imports updated if LSP supports it
```

#### Pattern 3: Multi-File Context for Claude
```vim
Space e        " Open explorer
Navigate to feature folder
V              " Select entire folder
Space as       " Add all to Claude
Space ac       " Open Claude
               " Ask: "Refactor these components to use hooks"
```

#### Pattern 4: Finding Files with Issues
```vim
Space e        " Open explorer
]d             " Jump to next file with diagnostics
               " Quickly find files with errors
```

---

## 9. Neovim Terminal Patterns

### Opening Terminals

```vim
Ctrl+/         " Toggle terminal (root dir) ⭐ FASTEST
Space ft       " Open terminal (root dir)
Space fT       " Open terminal (cwd)
```

**Terminal behavior:**
- Opens in **bottom split** by default
- Auto-enters **insert mode** (ready to type)
- Persists across sessions
- Stacks multiple terminals vertically

### Terminal Navigation

#### Entering/Exiting Terminal Mode
```vim
" Inside editor (normal mode):
Ctrl+/         " Open terminal → Auto-enters insert mode

" Inside terminal (insert mode):
Esc Esc        " Exit to normal mode (double-tap quickly)
i              " Re-enter insert mode
Ctrl+/         " Hide terminal (toggle)
q              " Hide terminal (when in normal mode)
```

**Pro Tip:** Double-tap `Esc` quickly (within 200ms) to exit terminal mode.

#### Window Navigation from Terminal

**THIS IS POWERFUL:**
```vim
" Even in terminal INSERT mode, you can navigate:
Ctrl+h         " Jump to left window
Ctrl+j         " Jump to window below
Ctrl+k         " Jump to window above
Ctrl+l         " Jump to right window
```

**Workflow Example:**
```vim
1. Coding in editor
2. Ctrl+/           " Open terminal (bottom split)
3. npm test         " Run tests
4. Ctrl+k           " Jump back to editor WITHOUT ESC!
5. Fix code
6. Ctrl+j           " Jump back to terminal
7. Tests auto-rerun
```

### Terminal Workflow Patterns

#### Pattern 1: Quick Command Execution
```vim
Ctrl+/         " Open terminal
npm run build  " Run command
Ctrl+k         " Back to editor (terminal stays open)
               " Check build output when needed
```

#### Pattern 2: Test-Driven Development
```vim
Space -        " Split editor below
Ctrl+/         " Open terminal in bottom
npm run test:watch  " Start test watcher

" Now you have:
" - Code editor (top)
" - Terminal with tests (bottom)

Ctrl+j/k       " Jump between code and tests
```

#### Pattern 3: Multiple Terminals
```vim
Ctrl+/         " Open terminal 1
npm run dev    " Start dev server
Ctrl+/         " Open terminal 2 (stacks below first)
npm run test   " Start tests

" Terminals stack vertically
" Navigate with Ctrl+j/k
```

#### Pattern 4: Terminal + File Explorer
```vim
Space e        " Open explorer (left)
Ctrl+/         " Open terminal (bottom)
Space -        " Split editor (middle)

" Layout:
" ┌─────────┬─────────┐
" │Explorer │  Code   │
" ├─────────┴─────────┤
" │    Terminal       │
" └───────────────────┘

Ctrl+h/j/k/l   " Navigate all windows
```

### Git Workflow in Neovim Terminal

**LazyGit is your PRIMARY git interface:**

```vim
Space gg       " Open LazyGit in Neovim terminal ⭐
```

**Inside LazyGit:**
```
Tab            " Switch between Files/Branches/Commits
Space          " Stage/unstage file
a              " Stage all files
c              " Commit (opens editor for message)
P              " Push to remote
p              " Pull from remote
x              " Open menu for more options
q              " Quit LazyGit
```

**Complete Git Workflow (Never Leave Neovim):**
```vim
1. Make code changes in editor
2. Space gg          " Open LazyGit
3. Space (on files)  " Stage changes
4. c                 " Commit (write message, save with :wq)
5. P                 " Push
6. q                 " Close LazyGit
7. Continue coding
```

**Pro Tip:** LazyGit has vim-style navigation (j/k/h/l), so it feels natural.

### Advanced Terminal Features

#### Opening Files from Terminal

```vim
" In terminal normal mode (Esc Esc):
gf             " Open file path under cursor in editor
               " Works with error messages, stack traces!
```

**Workflow Example:**
```vim
Ctrl+/         " Open terminal
npm test       " Test fails with file path
Esc Esc        " Exit to normal mode
/test/         " Search for file path
gf             " Open that file in editor ⭐
```

#### Terminal in Specific Directory

```vim
Space fT       " Open terminal in current file's directory
               " Useful for file-specific commands
```

#### Closing/Hiding Terminals

```vim
" From terminal insert mode:
Ctrl+/         " Hide terminal (doesn't kill process)

" From terminal normal mode:
q              " Hide terminal

" To kill terminal process:
:bd!           " Force close buffer (kills process)
```

---

## 10. Claude Code for Codebase Exploration

### The Ultimate "Living in Neovim" Workflow

With Claude Code, you can **explore ANY codebase without leaving Neovim**. This is your setup's most powerful feature.

### Quick Start: Exploring New Codebase

```vim
1. nvim .             " Open project in Neovim
2. Space e            " Open file explorer
3. Browse structure
4. Space ac           " Open Claude Code
5. Ask: "What does this codebase do?"
6. Claude explores and explains
```

### Adding Context to Claude

#### Method 1: Current Buffer
```vim
Space ab       " Add current file to Claude's context
               " Use when you're already viewing the file
```

#### Method 2: Visual Selection
```vim
1. Enter visual mode (v or V)
2. Select code you want Claude to see
3. Space as    " Send selection to Claude
               " Great for specific functions/sections
```

#### Method 3: Multiple Files via Explorer
```vim
1. Space e     " Open file explorer
2. Navigate to folder
3. v           " Start visual selection
4. j/k         " Select multiple files
5. Space as    " Add all to Claude's context ⭐
6. Space ac    " Open Claude with all files loaded
```

#### Method 4: Quick Add from Fuzzy Finder
```vim
1. Space Space " Find file
2. Enter       " Open file
3. Space ab    " Add to Claude context
4. Repeat for more files
5. Space ac    " Open Claude with all context
```

### Codebase Exploration Workflows

#### Workflow 1: Understanding Architecture

```vim
GOAL: Understand how a new codebase is structured

1. nvim .              " Open in project root
2. Space e             " Open explorer
3. Navigate to src/ or main directory
4. V                   " Select entire directory
5. Space as            " Add all files to Claude
6. Space ac            " Open Claude
7. Ask: "Explain the architecture and file organization"
8. Claude analyzes structure
9. Ask follow-ups: "Where is authentication handled?"
10. Claude points to specific files
11. Space Space        " Fuzzy find those files
12. Review suggested files
```

**Pro Tip:** Start broad (whole directory), then narrow down to specific files based on Claude's answers.

#### Workflow 2: Debugging Unfamiliar Code

```vim
GOAL: Fix a bug in code you don't understand

1. Space /             " Grep for error message
2. Enter on result     " Jump to file with error
3. Read error in code
4. Space ab            " Add current file to Claude
5. Visual select error function
6. Space as            " Send function to Claude
7. Space ac            " Open Claude
8. Ask: "Why is this function failing?"
9. Claude explains logic
10. Ask: "How should I fix it?"
11. Claude suggests fix
12. Space aa           " Accept Claude's diff ⭐
13. :w                 " Save file
14. Ctrl+/             " Open terminal
15. npm test           " Verify fix
```

#### Workflow 3: Feature Discovery

```vim
GOAL: Find how a specific feature is implemented

1. Space ac            " Open Claude first
2. Ask: "Where is user authentication implemented?"
3. Claude suggests files
4. Space Space         " Fuzzy find suggested file
5. Open file
6. Space ab            " Add to context
7. Ask Claude: "Walk me through the auth flow"
8. Claude explains with code references
9. Use gd / gr to jump through definitions
10. Build mental model of feature
```

#### Workflow 4: Multi-File Refactoring

```vim
GOAL: Refactor a feature across multiple files

1. Space /             " Grep for feature code
2. Review search results
3. Space e             " Open explorer
4. Navigate to feature directory
5. V                   " Select all related files
6. Space as            " Add to Claude context
7. Space ac            " Open Claude
8. Ask: "Refactor these to use TypeScript interfaces"
9. Claude proposes changes for each file
10. For each file:
    - Review diff
    - Space aa         " Accept if good
    - Edit if needed
    - Space ad         " Reject if bad
11. Space gg           " Open LazyGit
12. Review all changes
13. Stage, commit, push
```

#### Workflow 5: Learning from Examples

```vim
GOAL: Learn how to implement something similar

1. Space /             " Grep for similar feature
2. Enter on best result
3. Space ab            " Add file to Claude
4. Visual select the pattern you like
5. Space as            " Send to Claude
6. Ask: "Explain how this pattern works"
7. Claude breaks down the code
8. Ask: "How would I apply this to [your use case]?"
9. Claude generates adapted code
10. Space aa           " Accept generated code
```

### Claude Code Best Practices

#### Do's
✅ **Add context incrementally** - Start with 1-2 files, add more as needed
✅ **Use visual selection** - Send only relevant code sections
✅ **Review diffs carefully** - Edit Claude's suggestions before accepting
✅ **Ask follow-up questions** - Claude remembers context
✅ **Combine with LSP** - Use `gd`/`gr` to jump while Claude explains

#### Don'ts
❌ **Don't add entire codebase** - Too much context confuses Claude
❌ **Don't accept blindly** - Always review diffs
❌ **Don't replace understanding** - Use Claude to learn, not just copy
❌ **Don't skip testing** - Always verify Claude's changes work

### Integration with Other Tools

#### Claude + File Explorer
```vim
" Browse structure visually, add context systematically"
Space e → V → Space as → Space ac
```

#### Claude + LSP Navigation
```vim
" Claude explains, LSP navigates"
Space ac → Ask question → gd/gr → Space ab → Ask more
```

#### Claude + Grep
```vim
" Find code, get it explained"
Space / → Enter → Space ab → Space ac → Ask
```

#### Claude + Git
```vim
" Get Claude's help, commit changes"
Space ac → Space aa (accept) → Space gg → commit
```

---

## 11. Git Operations in Neovim

### Complete Git Workflow Without Leaving Neovim

Your setup includes **LazyGit integration** - the fastest way to handle all git operations without context switching.

### Primary Git Interface: LazyGit

```vim
Space gg       " Open LazyGit (root directory) ⭐ PRIMARY
Space gG       " Open LazyGit (current directory)
```

**Complete Git Workflow:**
```vim
1. Make code changes
2. Space gg          " Open LazyGit in Neovim terminal
3. (In LazyGit) Stage, commit, push
4. q                 " Close LazyGit
5. Continue coding - never left Neovim!
```

### LazyGit Navigation & Operations

**Interface Sections (Switch with Tab):**
- **Files** - Working tree changes
- **Branches** - Local/remote branches
- **Commits** - Commit history
- **Stash** - Stashed changes

**Essential LazyGit Keys:**
```
NAVIGATION
Tab / Shift+Tab    " Switch between sections
j/k                " Move up/down
h/l                " Navigate commits (in Commits view)

STAGING
Space              " Stage/unstage file
a                  " Stage all files
d                  " Discard changes

COMMITTING
c                  " Commit staged changes (opens editor)
                   " Write message, save with :wq
A                  " Amend last commit

BRANCHES & REMOTE
P                  " Push to remote
p                  " Pull from remote
o                  " Create new branch
Space              " Checkout branch (when in Branches view)

VIEWING
Enter              " View file diff
]c / [c            " Next/prev hunk in diff

UTILITIES
x                  " Open command menu
?                  " Show help
q                  " Quit LazyGit
```

### Git Operations (Alternative/Quick Access)

**File-Level Git Operations:**
```vim
Space gb           " Git blame line (shows who wrote it)
Space gB           " Git browse (open in GitHub browser)
Space gY           " Copy GitHub URL to clipboard
Space gf           " Git file history (shows file's commits)
```

**Diff & Status:**
```vim
Space gd           " Git diff (hunks in current file)
Space gD           " Git diff (against origin)
Space gs           " Git status
Space gS           " Git stash list
```

**Commit & Log:**
```vim
Space gl           " Git log (root)
Space gL           " Git log (cwd)
Space gc           " Git commits (telescope picker)
```

**GitSigns (Hunk Navigation):**
```vim
]h / [h            " Next/prev git hunk
]c / [c            " Next/prev git change (in diff view)
```

### Git Workflow Patterns

#### Pattern 1: Standard Commit Flow
```vim
" Make changes in editor
Space gg           " Open LazyGit
j/k                " Navigate to files
Space              " Stage files (or 'a' for all)
c                  " Commit
                   " Type message in editor, :wq to save
P                  " Push
q                  " Close LazyGit
```

#### Pattern 2: Quick Blame Investigation
```vim
" See weird code
Space gb           " Blame line
                   " See who wrote it and when
Enter              " Jump to commit (if using telescope)
                   " See full context
```

#### Pattern 3: Reviewing Changes Before Commit
```vim
Space gg           " Open LazyGit
Space              " Stage file
Enter              " View diff
]c / [c            " Navigate hunks
q                  " Close diff
c                  " Commit if good, or...
d                  " Discard if bad
```

#### Pattern 4: Branch Management
```vim
Space gg           " Open LazyGit
Tab                " Switch to Branches section
o                  " Create new branch
                   " Type name, Enter
                   " Automatically checks out
q                  " Close LazyGit
                   " Start working on new branch
```

#### Pattern 5: Fixing Commits
```vim
Space gg           " Open LazyGit
Tab                " Go to Commits section
Enter              " Select commit to view
r                  " Reword commit message
                   " Edit message, :wq to save
P                  " Force push (if needed)
q                  " Close LazyGit
```

#### Pattern 6: GitHub Integration
```vim
" Want to share code with team
Visual select code
Space gB           " Open selection in GitHub browser
                   " URL opens in browser with line numbers
                   " Share URL with team
```

### Git Best Practices in Neovim

**Do's:**
✅ Use `Space gg` for ALL git operations (staging, committing, pushing)
✅ Review diffs with `Enter` before committing
✅ Use `Space gb` to blame lines when debugging
✅ Stage incrementally (review each file with `Space`)
✅ Write descriptive commit messages

**Don'ts:**
❌ Don't use WezTerm for git (LazyGit in Neovim is faster)
❌ Don't force push without checking branches first
❌ Don't commit without reviewing diffs
❌ Don't bypass LazyGit for complex operations

---

## 12. Session & Workspace Management

### Automatic Session Persistence

Your setup uses **persistence.nvim** for automatic session management. Sessions restore your entire workspace: buffers, windows, splits, and cursor positions.

### Session Keybindings

```vim
Space qs           " Save session
Space qS           " Choose session from list
Space ql           " Restore last session
Space qd           " Don't save current session (disable for this directory)
Space qq           " Quit all windows
```

### How Sessions Work

**Automatic Behavior:**
- Sessions auto-save when you exit Neovim (`:qa`, `:q`, `Space qq`)
- Each directory gets its own session file
- Next time you open Neovim in that directory:
  - Dashboard shows "Restore Session" option (press `s`)
  - OR manually restore with `Space ql`

**What Gets Saved:**
- All open buffers and their content
- Window layout (splits, positions, sizes)
- Cursor positions in each buffer
- Working directory
- Marks and jumps

**What Doesn't Get Saved:**
- Terminal processes (terminals reopen but processes don't restart)
- File explorer state
- Unsaved changes (save files first!)

### Session Workflow Patterns

#### Pattern 1: Standard Daily Workflow
```vim
MORNING:
nvim                   " Open Neovim (in project directory)
(Dashboard appears)
s                      " Press 's' to restore session
                       " All yesterday's work restored instantly

EVENING:
Space qq               " Quit all (auto-saves session)
                       " or just :qa
```

#### Pattern 2: Manual Session Management
```vim
" Working on project
Space qs               " Save session now (don't wait for quit)

" Switch to different project
:cd ~/other-project
Space ql               " Load session for this directory

" Return to first project
:cd ~/first-project
Space ql               " Restore first project's session
```

#### Pattern 3: Multi-Project Context Switching
```vim
PROJECT A:
nvim ~/project-a
Space ql               " Restore project A session
                       " Work on Project A
Space qq               " Quit (auto-saves)

PROJECT B:
nvim ~/project-b
Space ql               " Restore project B session
                       " Work on Project B
                       " Completely different files/layout
```

#### Pattern 4: Starting Fresh
```vim
" Want clean slate (no session restore)
nvim                   " Open Neovim
Space qd               " Don't save current session
:qa                    " Quit
nvim                   " Reopen
                       " No session restored, fresh start
```

#### Pattern 5: Session Selection
```vim
Space qS               " Show all available sessions
j/k                    " Navigate session list
Enter                  " Restore selected session
                       " Switch between different project contexts
```

### Session Best Practices

**Do's:**
✅ Let sessions auto-save (don't overthink it)
✅ Use `:w` frequently to save file changes
✅ Use `Space ql` when returning to projects
✅ Use `Space qd` only when you want a fresh start
✅ One session per project directory

**Don'ts:**
❌ Don't manually save sessions constantly (`Space qs`)
❌ Don't restore sessions from other directories
❌ Don't quit without saving modified buffers
❌ Don't expect terminal processes to persist

### Integration with Other Tools

**Session + File Explorer:**
```vim
" Session restores, but explorer doesn't auto-open
Space e                " Open explorer if needed
                       " Cursor position in explorer NOT saved
```

**Session + Terminals:**
```vim
" Session restores terminal buffers but NOT processes
Ctrl+/                 " Terminal opens empty
npm run dev            " Restart dev server manually
```

**Session + Claude Code:**
```vim
" Session does NOT save Claude conversation
Space ac               " Open Claude fresh
Space ab               " Re-add buffers to context if needed
```

---

## 13. Neovim-Centric Daily Workflow Patterns

### Pattern 1: Morning Startup (Neovim Primary)
```vim
# In WezTerm:
cd ~/project
nvim .                 " Open Neovim in project

# In Neovim:
s                      " Restore session (from dashboard)
                       " All yesterday's work back

# Start working:
Space e                " Browse structure
Space Space            " Find files
Ctrl+/                 " Terminal for quick commands
Space gg               " LazyGit for git
```

### Pattern 2: Exploring New Codebase (All in Neovim)
```vim
nvim .                 " Open new project
Space e                " Open explorer
                       " Browse directory structure
V                      " Select directory
Space as               " Add to Claude context
Space ac               " Open Claude
                       " Ask: "Explain this codebase"
Space Space            " Open files Claude mentions
gd / gr                " Navigate code with LSP
```

### Pattern 3: Test-Driven Development (TDD in Neovim)
```vim
Space -                " Split window below
Ctrl+/                 " Open terminal in bottom split
npm run test:watch     " Start test watcher

" Layout:
" ┌─────────────────┐
" │   Code (top)    │
" ├─────────────────┤
" │  Tests (bottom) │
" └─────────────────┘

# Write test (top window)
# Watch it fail (bottom window)
Ctrl+k                 " Jump to code
# Write implementation
Ctrl+j                 " Jump to tests
# Watch it pass!
```

### Pattern 4: Full Git Workflow (Never Leave Neovim)
```vim
# Make code changes
Space cf               " Format code
:wa                    " Save all files
Space gg               " Open LazyGit
j/k                    " Navigate files
Space              " Stage files
c                      " Commit
# Write message, :wq
P                      " Push to remote
q                      " Close LazyGit
# Back to coding - never left Neovim!
```

### Pattern 5: Quick Search & Refactor
```vim
Space /                " Grep in project
# Type search term, Enter
Enter                  " Jump to first result
gd                     " Go to definition
Space ca               " Code action / quick fix
Space cr               " Rename symbol (LSP renames everywhere)
Space cf               " Format code
:w                     " Save
Space gg               " LazyGit
# Review changes, commit, push
```

### Pattern 6: Multi-Window Layout (All in Neovim)
```vim
Space e                " File explorer (left)
Space |                " Split right
Ctrl+l                 " Focus right window
Space -                " Split below
Ctrl+/                 " Terminal (bottom)

" Final layout:
" ┌─────────┬──────────┐
" │Explorer │  Code    │
" │ (left)  ├──────────┤
" │         │  Code 2  │
" ├─────────┴──────────┤
" │     Terminal       │
" └────────────────────┘

Ctrl+h/j/k/l           " Navigate all windows
# No context switching needed!
```

### Pattern 7: Claude-Assisted Debugging (Stay in Neovim)
```vim
# Code has bug
Ctrl+/                 " Open terminal
npm test               " Test fails
Esc Esc                " Exit terminal mode
/error-path            " Search for file path in error
gf                     " Open file under cursor ⭐
Space ab               " Add buffer to Claude
Visual select error
Space as               " Send to Claude
Space ac               " Open Claude
# "Why is this failing?"
# Claude explains issue
Space aa               " Accept Claude's fix
Ctrl+/                 " Back to terminal
# Test passes!
```

### Pattern 8: Multi-File Refactoring with Claude (Neovim Only)
```vim
Space e                " Open explorer
Navigate to directory
V                      " Select entire directory
Space as               " Add all to Claude
Space ac               " Open Claude
# "Refactor these to use TypeScript"
# Claude proposes changes

# For each file:
Space aa               " Accept diff
# or edit manually if needed

:wa                    " Save all files
Space gg               " Open LazyGit
# Review, commit, push
```

### Pattern 9: Codebase Learning Sprint (Claude + LSP)
```vim
Space ac               " Open Claude first
# "Where is authentication handled?"
# Claude: "Check src/auth/index.ts"
Space Space            " Find file: auth
Enter                  " Open file
gd                     " Jump to definitions
gr                     " See all references
Space ab               " Add to Claude context
# "Explain the auth flow step by step"
# Build understanding with Claude as tutor
]d                     " Navigate to next definition
# Repeat until you understand
```

### Pattern 10: Session Restoration + Immediate Productivity
```vim
# Morning:
nvim ~/project         " Open Neovim
s                      " Restore session (dashboard)
                       " All buffers restored instantly
Space ql               " Or manually restore
Ctrl+/                 " Terminal for server
npm run dev            " Start dev server
Ctrl+k                 " Back to code
# Ready to code in seconds!
```

### Pattern 11: Database Query Development (Neovim Only)
```vim
:DBUI                  " Open database UI
# Connect to database
# Write SQL query
# Execute

Space ac               " Open Claude
Space ab               " Add query + results
# "Optimize this for performance"
Space aa               " Accept optimized query
# Re-execute
# Compare performance
```

### Pattern 12: API Testing Workflow (Kulala + Claude)
```vim
# Create test.http file
Space e                " Find .http file
a                      " Create new file
api-test.http          " Name it

### Write request:
GET https://api.github.com/users/anthropics

# Execute request
Space ac               " Claude
Space ab               " Add response
# "Parse this and create TypeScript types"
Space aa               " Accept generated types
# Save types to new file
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

### 6. Which-Key Discovery System

Press `Space` and **wait 1 second** → Interactive keymap menu appears!
- Explore without memorizing everything upfront
- `Space c` → See all code actions
- `Space s` → See all search options
- `Space sk` → Search ALL keymaps in Telescope

### 7. Flash Navigation (s + 2 chars)

Instead of `10j` or `/search<Enter>`:
```vim
s{char}{char}     # Jump to any visible location
S                 # Jump to treesitter node (functions, classes)
```
**Pro tip**: Use `s` for 90% of navigation within a file

### 8. Yanky Yank History

```vim
yy                # Yank line
p                 # Paste
]p                # Cycle to next yank
[p                # Cycle to previous yank
Space p           # Browse full yank history (Telescope)
```
Never lose a yank again!

### 9. Treesitter Text Objects

```vim
daf               # Delete around function
dif               # Delete inside function
vac               # Visual select around class
cif               # Change inside function
```
**Pro tip**: Combine with operators (d/c/v/y) for powerful editing

### 10. Copilot + Claude Combo Strategy

- **Copilot** (inline): Auto-complete as you type (fast, line-level)
- **Claude Code**: Complex refactoring, architecture questions, debugging
- **Best practice**:
  - Use Copilot for boilerplate/autocomplete
  - Use Claude for reasoning/analysis/refactoring
  - Accept Copilot with Tab, reject with Esc

### 11. Claude as Your Vim Tutor

```vim
Space ac          # Open Claude
# Ask: "Teach me advanced vim text objects"
# Ask: "What's the difference between dap and dip?"
# Ask: "How do I use macros in vim?"
# Ask: "Review my code for anti-patterns"
```
Claude knows vim inside-out and can explain anything!

### 12. Persistent Sessions Workflow

```vim
Space qs          # Save session
Space ql          # Load last session
Space qd          # Don't save current session
```
Next time you `nvim` in same directory → Auto-restore!

### 13. Todo Comments Navigation

```vim
# In your code:
// TODO: Implement this
// FIXME: Bug here
// HACK: Temporary solution

]t / [t           # Jump between todos
Space st          # List all todos (Telescope)
Space xt          # Show todos in Trouble
```

---

## Learning Path: Living in Neovim

### Week 1: File Navigation & Basic Editing (Foundation)

```
Space Space         # Find files (PRIMARY navigation)
Space e             # File explorer
Space fr            # Recent files
gd / gr / K         # Code navigation (LSP)
Space ca            # Code actions
Shift+H/L           # Buffer cycling
```

**Goal**: Master file navigation and basic code movement in Neovim.

**Practice Exercises**:
1. Open Neovim, find 10 files with `Space Space`
2. Use `Space e` to browse structure, practice `h/j/k/l`
3. Jump between definitions with `gd`, references with `gr`
4. Use `K` to view hover documentation
5. Practice `Space ca` for quick fixes
6. **Challenge**: Complete a small bug fix without leaving Neovim

**Milestone**: Can navigate any codebase using only keyboard.

### Week 2: Integrated Terminal & Git (Stay in Neovim)

```
Ctrl+/              # Toggle terminal
Ctrl+h/j/k/l        # Window navigation (works in terminal!)
Space gg            # LazyGit (PRIMARY git interface)
Space gb            # Git blame
Esc Esc             # Exit terminal mode
```

**Goal**: Stop using WezTerm for git/commands, use Neovim terminal.

**Practice Exercises**:
1. Open terminal with `Ctrl+/`, run commands
2. Practice `Ctrl+k` to jump back to editor FROM terminal
3. Use `Space gg` for all git operations (stage, commit, push)
4. Practice LazyGit navigation (`j/k`, `Space`, `c`, `P`)
5. Set up multi-window layout: explorer + code + terminal
6. **Challenge**: Complete full git workflow without leaving Neovim

**Milestone**: All git operations happen in Neovim, WezTerm only for servers.

### Week 3: Claude Code Integration (Codebase Exploration)

```
Space ac            # Toggle Claude
Space ab            # Add buffer to context
Space as            # Send selection (visual mode)
Space aa / ad       # Accept/Deny diffs
Space e → V → Space as  # Add directory to Claude
```

**Goal**: Use Claude to explore and understand codebases.

**Practice Exercises**:
1. Open unfamiliar codebase, use `Space e` + Claude to explore
2. Select files with `V` in explorer, `Space as` to add to Claude
3. Ask Claude: "Explain the architecture"
4. Practice visual selection + `Space as` for code snippets
5. Use `Space aa` to accept suggestions, `Space ad` to reject
6. **Challenge**: Understand new codebase in 30 minutes using Claude

**Milestone**: Claude is your primary tool for exploring unknown code.

### Week 4: Advanced Navigation & Editing

```
s{char}{char}       # Flash navigation (replace arrow keys!)
daf / dif / vac     # Treesitter text objects
Space /             # Grep in project
Space sr            # Search & replace
]d / [d             # Navigate diagnostics
Space cr            # LSP rename
```

**Goal**: Edit code with surgical precision using advanced movements.

**Practice Exercises**:
1. Use `s` exclusively for navigation (no arrow keys)
2. Practice `daf` (delete function), `vac` (select class)
3. Use `Space /` to find code, `Space sr` to refactor
4. Practice `Space cr` for renaming (updates all references)
5. Navigate errors with `]d`, fix with `Space ca`
6. **Challenge**: Refactor a feature without using mouse or arrows

**Milestone**: Vim motions feel faster than scrolling.

### Week 5: Multi-Window Workflows (Complete Integration)

```
Space -  / Space |  # Split windows
Space e             # Explorer left
Ctrl+/              # Terminal bottom
Ctrl+h/j/k/l        # Navigate all windows
Space wd            # Close window
```

**Goal**: Work with complex layouts entirely in Neovim.

**Practice Exercises**:
1. Set up 4-pane layout: Explorer + Code + Code + Terminal
2. Practice `Ctrl+h/j/k/l` navigation between all windows
3. Run tests in terminal while coding in top window
4. Use explorer to add files to Claude, code in main window
5. **Challenge**: TDD workflow - tests bottom, code top, never leave Neovim

**Milestone**: WezTerm only runs dev server, everything else in Neovim.

### Week 6: Session Management & Productivity

```
Space ql            # Restore session
Space qs            # Save session
Space qq            # Quit all (auto-saves)
s (dashboard)       # Restore session on startup
```

**Goal**: Instant context restoration between work sessions.

**Practice Exercises**:
1. Work on project, `Space qq` to quit
2. Reopen Neovim, press `s` on dashboard to restore
3. Practice multi-project switching with sessions
4. Use `Space qd` to start fresh when needed
5. **Challenge**: Work on 3 projects, switching seamlessly with sessions

**Milestone**: Start coding within 5 seconds of opening Neovim.

### Week 7-8: Complete "Living in Neovim" Mastery

**Goals**:
- **95% of workflow in Neovim**: File nav, git, terminal, Claude, editing
- **WezTerm only for servers**: Long-running processes only
- **Claude as pair programmer**: First stop for debugging/refactoring
- **Zero context switching**: Entire workflow keyboard-driven
- **Session muscle memory**: Restore → Work → Quit → Repeat

**Daily Workflow**:
```vim
Morning:
nvim ~/project → s (restore) → Coding

Throughout day:
Space Space        " Find files
Space e            " Explore structure
Ctrl+/             " Quick commands
Space gg           " Git operations
Space ac           " Claude assistance
Ctrl+h/j/k/l       " Window navigation

Evening:
Space qq           " Quit (auto-saves session)
```

**Signs of Mastery**:
✅ Open Neovim first, not terminal
✅ Complete git workflows without WezTerm
✅ Explore codebases with Claude + explorer
✅ Terminal navigation with `Ctrl+k` is automatic
✅ Sessions restore instantly
✅ **Never use mouse or Alt+Tab**
✅ Teach others the "Living in Neovim" approach

**Final Challenge**: Spend entire day coding, only opening WezTerm for dev server.

---

## Living in Neovim: Quick Decision Trees

### "Where should I work?"

```
Need to code/edit/git? ──→ Open Neovim (95% of time)
Need to run dev server? ─→ Open WezTerm (5% of time)
```

### "How do I navigate files?"

```
Know file name? ───────────→ Space Space (fuzzy finder)
Need to see structure? ────→ Space e (file explorer)
Recently worked on? ───────→ Space fr or Shift+H/L
Want Claude to analyze? ───→ Space e → V → Space as
```

### "Where should I run commands?"

```
Quick command? ────────────→ Ctrl+/ (Neovim terminal)
Git operation? ────────────→ Space gg (LazyGit in Neovim)
Long-running server? ──────→ WezTerm
```

### "How do I get help?"

```
Unknown codebase? ─────────→ Space ac (Claude Code)
Error message? ────────────→ Space ab → Space ac (Claude)
LSP documentation? ────────→ K (hover)
Keybinding forgotten? ─────→ Space (wait 1s, Which-Key)
```

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

## Quick Reference Summary

### Top 30 Keymaps to Memorize

#### Navigation (10)
1. `Space Space` - Find files
2. `Space /` - Grep search
3. `gd` - Go to definition
4. `gr` - Find references
5. `Shift+H/L` - Switch buffers
6. `Alt+b/t/d` - Switch workspaces
7. `Alt+h/j/k/l` - Focus windows
8. `Ctrl+h/j/k/l` - Navigate splits
9. `s{char}{char}` - Flash jump
10. `Alt+Tab` - Toggle workspaces

#### Editing (10)
11. `Space ca` - Code action ⭐⭐⭐
12. `Space cr` - Rename symbol
13. `Space cf` - Format code
14. `K` - Hover docs
15. `]d / [d` - Navigate errors
16. `gcc` - Comment line
17. `daf/dif` - Delete function
18. `Space -/|` - Create split
19. `]p / [p` - Yank history
20. `:w` - Save

#### Claude AI (5)
21. `Space ac` - Toggle Claude
22. `Space ab` - Add buffer
23. `Space as` - Send selection
24. `Space aa` - Accept diff
25. `Space ad` - Deny diff

#### Neovim Terminal (3) ⭐ LIVING IN NEOVIM
26. `Ctrl+/` - Toggle terminal
27. `Ctrl+h/j/k/l` - Navigate windows (works in terminal!)
28. `Space gg` - LazyGit

#### File Explorer (3)
29. `Space e` - Toggle explorer
30. `Space as` (in explorer) - Add files to Claude
31. `P` (in explorer) - Preview file

#### Session Management (2)
32. `Space ql` - Restore session
33. `Space qq` - Quit all (auto-save session)

---

## Further Reading

- **[LazyVim Keymaps Documentation](https://www.lazyvim.org/keymaps)** - Official LazyVim keybindings
- **[Claude Code Plugin](https://github.com/coder/claudecode.nvim)** - Official claudecode.nvim repository
- **[Aerospace Window Manager](https://github.com/nikitabobko/AeroSpace)** - i3-like tiling for macOS
- **[WezTerm Configuration](https://wezfurlong.org/wezterm/config/files.html)** - GPU-accelerated terminal
- **[Comprehensive Setup Guide](GUIDE.md)** - Architecture, design decisions, troubleshooting

---

## Summary Statistics

**Your Complete Setup:**
- **Neovim**: 0.11.4 with LazyVim
- **Plugins**: 58 installed
- **AI**: Claude Code + GitHub Copilot + Blink Copilot
- **Theme**: Tokyo Night (unified across all tools)
- **Terminal**: WezTerm (for long-running servers) + Neovim terminal (for everything else)
- **Window Manager**: Aerospace (i3-like tiling)
- **Philosophy**: **Living in Neovim** - 95% of workflow without leaving editor

**"Living in Neovim" Essentials:**
1. `Space Space` - Find files (primary navigation)
2. `Space e` - File explorer (structure + Claude context)
3. `Ctrl+/` - Neovim terminal (quick commands)
4. `Space gg` - LazyGit (all git operations)
5. `Space ac` - Claude Code (codebase exploration)
6. `Ctrl+h/j/k/l` - Window navigation (even from terminal!)
7. `Space ql` - Session restore (instant context)

**Workflow Distribution:**
- **Neovim**: 95% (code, files, git, terminal, Claude)
- **WezTerm**: 5% (dev servers, long-running processes only)

**Power Features:**
- **Snacks Explorer** - File management + Claude integration
- **Integrated Terminal** - `Ctrl+k` navigation from terminal mode
- **LazyGit in Neovim** - Complete git workflow without context switch
- **Claude Code** - Codebase exploration without leaving editor
- **Session Persistence** - Auto-restore workspace on `nvim` open
- **Which-Key** - Discover keybindings (`Space` + wait)
- **Flash Navigation** - Jump anywhere with `s` + 2 chars
- **LSP Integration** - Code intelligence everywhere
- **Debugging (DAP)** - Full debugging in Neovim
- **Testing (Neotest)** - TDD workflow in split windows

**What Changed:**
- **Before**: WezTerm for terminal + git, Neovim for editing
- **After**: Neovim for EVERYTHING, WezTerm only for servers
- **Key Insight**: `Ctrl+/` terminal + `Space gg` LazyGit = never leave Neovim

---

**Built with:** LazyVim (58 plugins), Claude Code AI, Snacks.nvim suite, WezTerm (minimal use), Aerospace, Tokyo Night, and the "Living in Neovim" philosophy.
