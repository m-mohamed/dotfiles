# Dotfiles Quick Start Onboarding Guide

Welcome to your new development environment! This guide focuses on the **essential keys and flows** you need to know right away.

## Table of Contents
- [Shell (ZSH Vi Mode)](#shell-zsh-vi-mode)
- [Window Management (AeroSpace)](#window-management-aerospace)
- [Terminal (WezTerm)](#terminal-wezterm)
- [Modern CLI Tools](#modern-cli-tools)
- [Common Workflows](#common-workflows)
- [Quick Reference Card](#quick-reference-card)

---

## Shell (ZSH Vi Mode)

Your shell uses **Pure Vi Mode** - no Emacs shortcuts. The cursor changes to show you which mode you're in.

### Visual Feedback
- **| Beam cursor** = INSERT mode (typing)
- **█ Block cursor** = COMMAND mode (navigation/editing)

### Mode Switching
```bash
jk              # Exit to command mode (faster than Esc)
i               # Enter insert mode (at cursor)
a               # Enter insert mode (after cursor)
I               # Insert at beginning of line
A               # Append at end of line
```

### Navigation (Command Mode)
```bash
h               # Move left
l               # Move right
0               # Beginning of line
$               # End of line
w               # Next word
b               # Previous word
```

### Editing (Command Mode)
```bash
dw              # Delete word
dd              # Delete line
cw              # Change word (delete + insert)
ciw             # Change inner word (cursor anywhere in word)
ci"             # Change inside quotes
dt.             # Delete until period
x               # Delete character
```

### History Search
```bash
Ctrl+R          # Fuzzy search command history (fzf)
/               # Search history backward (in command mode)
?               # Search history forward (in command mode)
n               # Next match
N               # Previous match
```

### Tab Completion
```bash
<Tab>           # Show completions
h j k l         # Navigate completion menu (vim keys!)
<Enter>         # Accept selection
```

---

## Window Management (AeroSpace)

AeroSpace is your tiling window manager. Everything uses **Alt** as the modifier.

### Workspace Navigation (Mnemonic Letters)
```bash
Alt+B           # Browser workspace
Alt+T           # Terminal workspace
Alt+D           # Development workspace
Alt+M           # Media workspace
Alt+S           # Slack workspace
Alt+E           # Email workspace

Alt+Tab         # Toggle between last two workspaces
Alt+U           # Previous workspace
Alt+I           # Next workspace
```

### Window Focus (Vim Keys)
```bash
Alt+h           # Focus left
Alt+j           # Focus down
Alt+k           # Focus up
Alt+l           # Focus right
```

### Move Windows
```bash
Alt+Shift+h     # Move window left
Alt+Shift+j     # Move window down
Alt+Shift+k     # Move window up
Alt+Shift+l     # Move window right

Alt+Shift+B     # Move window to Browser workspace
Alt+Shift+T     # Move window to Terminal workspace
Ctrl+Shift+D    # Move window to Development workspace
Alt+Shift+M     # Move window to Media workspace
Alt+Shift+S     # Move window to Slack workspace
Ctrl+Shift+E    # Move window to Email workspace
```

### Layout Control
```bash
Alt+/           # Toggle layout (horizontal/vertical tiles)
Alt+,           # Toggle accordion (stacked) layout
Alt+Shift+F     # Toggle fullscreen
Alt+Shift+Space # Toggle floating/tiling
```

### Resize Windows
```bash
Alt+Shift+-     # Shrink window
Alt+Shift+=     # Grow window

Alt+R           # Enter RESIZE MODE (then use vim keys)
  h             # Shrink width
  l             # Grow width
  k             # Shrink height
  j             # Grow height
  Shift+hjkl    # Fine adjustments (10px)
  b             # Balance all windows
  <Esc>         # Exit resize mode
```

### Service Mode (Advanced Operations)
```bash
Alt+Space       # Enter SERVICE MODE
  f             # Toggle floating
  b             # Balance all window sizes
  h/j/k/l       # Join window with neighbor
  -             # Flatten layout (reset)
  <Backspace>   # Close all windows but current
  <Esc>         # Exit service mode
```

### Monitor Management
```bash
Alt+P           # Focus previous monitor
Alt+N           # Focus next monitor
Alt+Shift+P     # Move window to previous monitor
Alt+Shift+N     # Move window to next monitor
```

---

## Terminal (WezTerm)

WezTerm uses a **Leader key** pattern (like tmux). The leader is **Ctrl+G**.

### Leader Key Pattern
1. Press **Ctrl+G** (you'll see "LEADER" in status bar)
2. Within 1 second, press the command key
3. Leader auto-releases after command

### Pane Management (Vim Keys)
```bash
Ctrl+G h        # Focus pane left
Ctrl+G j        # Focus pane down
Ctrl+G k        # Focus pane up
Ctrl+G l        # Focus pane right

Ctrl+G s        # Split vertically (new pane below)
Ctrl+G v        # Split horizontally (new pane right)
Ctrl+G z        # Toggle pane zoom (fullscreen)
Ctrl+G q        # Close current pane
```

### Tab Management
```bash
Ctrl+G t        # New tab
Ctrl+G ]        # Next tab
Ctrl+G [        # Previous tab
Ctrl+G c        # Close tab (with confirmation)
Ctrl+G b        # Show tab navigator
Ctrl+G r        # Rename tab

Ctrl+G Shift+H  # Move tab left
Ctrl+G Shift+L  # Move tab right
```

### Workspace Management
```bash
Ctrl+G w        # Show workspace picker
Ctrl+G e        # Switch to workspace (prompt)
Ctrl+G Shift+R  # Rename current workspace
```

### Session Management
```bash
Ctrl+G a        # Attach to unix domain
Ctrl+G d        # Detach from unix domain
```

### Utilities
```bash
Ctrl+G Space    # QuickSelect (pick URLs, paths, git SHAs)
Ctrl+G p        # Show launcher menu

Cmd+C           # Copy
Cmd+V           # Paste
Cmd+K           # Clear scrollback

Shift+PageUp    # Scroll up
Shift+PageDown  # Scroll down

Ctrl++          # Increase font size
Ctrl+-          # Decrease font size
Ctrl+0          # Reset font size
```

---

## Modern CLI Tools

Your dotfiles replace traditional Unix tools with modern, faster alternatives.

### File Listing (eza replaces ls)
```bash
ls              # List files (actually: eza --icons)
ll              # Long format with git status
la              # Show hidden files
tree            # Tree view (eza --tree)
tree -L 2       # Tree with depth limit
```

### File Viewing (bat replaces cat)
```bash
cat file.txt    # Syntax highlighted (actually: bat)
less file.txt   # Paged view with highlighting (bat)
bat --plain     # Show without line numbers/decorations
```

### Fuzzy Search (fzf)
```bash
Ctrl+R          # Search command history
Ctrl+T          # Search files in current directory
Alt+C           # Search directories and cd into one

# In any command:
vim **<Tab>     # Fuzzy find file to edit
cd **<Tab>      # Fuzzy find directory to cd into
```

### Smart Navigation (zoxide replaces cd)
```bash
z dotfiles      # Jump to ~/dotfiles (frecency-based)
z dot<Tab>      # Fuzzy complete directory names
zi              # Interactive directory picker
```

### File Search (fd replaces find)
```bash
fd pattern      # Find files matching pattern
fd -e ts        # Find TypeScript files
fd -t f         # Find files only
fd -t d         # Find directories only
fd -H           # Include hidden files
```

### Content Search (ripgrep)
```bash
rg "pattern"    # Search for pattern in files
rg -i "text"    # Case insensitive
rg -t ts "fn"   # Search only TypeScript files
rg -l "import"  # List files with matches
```

### Git Diff (delta)
```bash
git diff        # Shows enhanced diff with syntax highlighting
git log -p      # Shows commit history with beautiful diffs
git show HEAD   # Shows last commit with side-by-side diff
```

---

## Common Workflows

### Starting Your Day
```bash
# 1. Open terminal (WezTerm auto-connects to persistent session)
# 2. Navigate to project
z myproject         # Jump with zoxide

# 3. Open in editor
v .                 # Open neovim in current directory

# 4. Check git status
gits               # alias for git status
gitl               # alias for git lg (pretty log)
```

### Working with Multiple Projects
```bash
# Terminal workspace setup
Alt+T               # Switch to Terminal workspace
Ctrl+G t            # New tab for second project
Ctrl+G r            # Rename tab "api"
z api && v .        # Navigate and open editor

Ctrl+G t            # New tab for third project
Ctrl+G r            # Rename tab "frontend"
z frontend && v .

# Switch between projects
Ctrl+G [            # Previous tab
Ctrl+G ]            # Next tab
Ctrl+G b            # Show all tabs visually
```

### Window Layout for Focused Work
```bash
# 1. Browser on left, editor on right
Alt+B               # Switch to Browser workspace
# Open browser if needed
Alt+D               # Switch to Development workspace
# Open editor
Alt+l               # Focus right (to editor)
Alt+Shift+/         # Toggle horizontal/vertical layout

# 2. Terminal splits for monitoring
Ctrl+G s            # Split vertically (logs below)
Ctrl+G k            # Focus back up
npm run dev         # Start dev server

Ctrl+G j            # Focus down
tail -f app.log     # Monitor logs

Ctrl+G z            # Zoom focused pane when needed
```

### Quick File Navigation
```bash
# Find and open file
Ctrl+T              # Fuzzy find file
# Type partial name, press Enter
v <selected-file>

# Or combined:
v $(fd pattern | fzf)   # Find files, fuzzy select, open in vim

# Jump to recent directory
z <partial-name><Tab>   # Fuzzy complete directories
```

### Git Workflow
```bash
# Check what changed
gits                # git status
gitd                # git diff (with delta highlighting)

# Stage and commit
gita                # git add . (add all)
gitc                # cz commit (commitizen - interactive)

# View history
gitl                # git lg (pretty log graph)
git show HEAD       # See last commit with diff

# Use lazygit for visual interface
lg                  # Launch lazygit
```

### Editing Commands
```bash
# You typed a long command with a typo
# Instead of retyping:

# Example: gti status
# Press: jk (enter command mode)
# Press: Fgr (find 'g' backward, replace)
# Type: git
# Result: git status

# Or change entire word:
# Press: jk (command mode)
# Press: Bcw (back word, change word)
# Type: git
```

---

## Quick Reference Card

### Most Important Keys

| Context | Action | Keys |
|---------|--------|------|
| **Shell** | Exit to command mode | `jk` |
| | History search | `Ctrl+R` |
| | File picker | `Ctrl+T` |
| **AeroSpace** | Switch workspace | `Alt+B/T/D/M/S/E` |
| | Focus window | `Alt+h/j/k/l` |
| | Move window | `Alt+Shift+h/j/k/l` |
| | Resize mode | `Alt+R` |
| | Service mode | `Alt+Space` |
| **WezTerm** | Leader key | `Ctrl+G` |
| | Split panes | `Ctrl+G s/v` |
| | Focus panes | `Ctrl+G h/j/k/l` |
| | New tab | `Ctrl+G t` |
| | Switch tabs | `Ctrl+G [/]` |

### Aliases You'll Use Daily

```bash
# Editing
v, vi, vim          # nvim
c                   # clear
zshconfig           # Edit ~/.zshrc
gitconfig           # Edit ~/.gitconfig

# Git
gits                # git status
gitd                # git diff
gitl                # git log (pretty)
gita                # git add .
gitc                # cz commit
lg                  # lazygit

# Development
pn                  # pnpm
ld                  # lazydocker
```

---

## Tips for Success

### Week 1: Getting Comfortable
- **Don't panic** when you hit the wrong key - `jk` gets you back to safety
- Practice vi mode in the shell - it builds muscle memory for Vim
- Use `Ctrl+R` constantly - fuzzy history is amazing
- Set up your workspaces: Browser (Alt+B), Terminal (Alt+T), Editor (Alt+D)

### Week 2: Building Speed
- Learn `ci"` and `ciw` - they're game changers
- Use `z` instead of `cd` - let it learn your patterns
- Master WezTerm splits - `Ctrl+G s/v/h/j/k/l`
- Try lazygit (`lg`) for visual git workflows

### Week 3: Advanced Flows
- Customize workspaces for your projects
- Use AeroSpace resize mode for perfect layouts
- Add your own aliases to `~/.config/zsh/modules/03-aliases.zsh`
- Explore the comprehensive GUIDE.md for deep dives

---

## Need Help?

- **Comprehensive docs**: See `GUIDE.md` (1,800+ lines of deep documentation)
- **Performance issues**: Run `./scripts/benchmark.sh`
- **Plugin issues**: `antidote update && exec zsh`
- **Completion issues**: `rm ~/.cache/zsh/.zcompdump* && exec zsh`

---

## Your Environment at a Glance

- **Shell**: ZSH with <100ms startup
- **Terminal**: WezTerm with persistent Unix domains
- **Editor**: Neovim (LazyVim)
- **Window Manager**: AeroSpace (i3/sway-inspired)
- **Theme**: Tokyo Night (consistent everywhere)
- **Modern Tools**: eza, bat, fzf, ripgrep, fd, delta, zoxide

**You're all set!** Start with basic navigation (Alt+hjkl, jk, Ctrl+R) and build from there. The muscle memory will click in about 2 weeks.

Happy hacking! 🚀
