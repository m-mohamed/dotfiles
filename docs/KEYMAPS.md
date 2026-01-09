# Essential Keymaps Cheat Sheet

**Last Updated:** 2025-11-17
**Version:** LazyVim 2.0 + Snacks.nvim Suite

Your complete guide to living in LazyVim, complemented by WezTerm and Aerospace.

---

## Quick Reference

### Top 20 Muscle Memory Keybindings

```
LazyVim:     Space Space / gd / K / Space ca / Shift+H/L / Ctrl+/
Obsidian:    Space ot / Space oo / Space os
WezTerm:     Ctrl+a → s/v/h/j/k/l/q/z
Aerospace:   Alt+h/j/k/l / Alt+b/t/d
```

### Where You Actually Spend Time

```
LazyVim:    80% - File nav, code, git, terminal, AI, notes
WezTerm:    15% - Long-running servers only
Aerospace:   5% - Window management
```

---

## Your Setup

**LazyVim Distribution:**

- Neovim: 0.11.4
- Plugins: 59 installed
- LazyVim Extras: 25 enabled
- Completion: **blink.cmp** (Rust-based, ultra-fast)
- Picker: **Snacks picker** (NOT Telescope)
- File Explorer: **Snacks explorer**
- Terminal: **Snacks terminal**
- Theme: Tokyo Night (night variant)

**Philosophy:**

- Minimal custom config (only 6 keybinding deletions for Aerospace conflicts)
- Trust LazyVim defaults
- Living in Neovim for 95% of workflow

---

## 1. LazyVim/Neovim

### Leader Key

**`Space`** - Your primary command key

### Important: Disabled Keybindings

**Alt+j/k line movement** has been disabled to prevent conflicts with Aerospace window navigation.

**Alternatives:**

- `]e` / `[e` - Move line up/down (LazyVim default)
- Visual mode + `:m '>+1` or `:m '<-2`
- `dd` then `p`/`P`

---

### File Navigation

Your primary navigation methods, ranked by frequency of use.

#### Primary: Find Files (Snacks Picker)

**`Space Space`** - Find files (fuzzy search)

- Use this 80% of the time
- Fastest way to open any file
- Type partial filename, instantly jump

**Quick Workflow:**

```vim
1. Space Space      # Open picker
2. Type filename    # Fuzzy search
3. Enter            # Open file
```

**Alternative:**

```vim
Space ff            # Same as Space Space
Space fg            # Find git files only
Space fF            # Find files (cwd instead of root)
```

#### Visual: File Explorer (Snacks Explorer)

**`Space e`** - Toggle file explorer (root)

Use when you need to:

- See directory structure visually
- Perform file operations (create, rename, delete)
- See git status markers

**Within Explorer:**

**Navigation:**

```vim
j/k             # Move up/down
l or Enter      # Open file / expand folder
h               # Close folder / go to parent
H               # Toggle hidden files
I               # Toggle ignored files (gitignore)
```

**File Operations:**

```vim
a               # Add new file/folder (end with / for folder)
d               # Delete file/directory
m               # Move/rename
c               # Copy
y               # Yank (copy path)
p               # Paste
```

**Selection:**

```vim
v / V           # Visual selection (multi-file)
```

**Preview:**

```vim
P               # Toggle preview window
```

**Alternative:**

```vim
Space E         # Toggle explorer (cwd instead of root)
```

#### Recent: File History

**`Space fr`** - Recent files

Use for jumping back to recently edited files.

**Alternative:**

```vim
Space fR        # Recent files (cwd only)
Shift+H/L       # Cycle through buffer history
```

#### Hidden Files (.env, .gitignore, dotfiles)

**The Issue:** By default, Snacks picker hides dotfiles (files starting
with `.`) in file searches and grep results. This includes `.env`,
`.gitignore`, `.zshrc`, etc.

**Why:** Performance optimization and clutter reduction. Most searches
don't need to scan hidden config files.

**Runtime Toggle (No Config Change Needed):**

```vim
Alt-h           # Toggle hidden files in picker (Space Space / Space /)
M-i             # Toggle gitignored files in picker
H               # Toggle hidden files in explorer (Space e)
```

**Workflow Example:**
1. `Space Space` - Open file picker (dotfiles hidden)
2. `Alt-h` - Toggle to show hidden files
3. Type `.env` - Now you can see and select it
4. `Alt-h` again - Hide dotfiles again for normal work

**Permanent Solution (Config):**

If you want hidden files visible by default, create
`nvim/.config/nvim/lua/plugins/snacks.lua`:

```lua
return {
  "folke/snacks.nvim",
  opts = {
    picker = {
      sources = {
        files = { hidden = true },
        grep = { hidden = true },
        explorer = { hidden = true },
      },
    },
  },
}
```

**Known Bug:** If a directory contains ONLY hidden files, picker may
show "No results" even after toggling. This is a known issue in Snacks
picker (#808).

**Note:** Your `.gitignore` patterns don't affect this behavior. Hidden
files are filtered separately by the picker itself, not git.

---

### Search

Search across your entire project using Snacks picker.

#### Primary: Grep Search

**`Space /`** - Grep in project (root directory)

Search for text across all files.

**Quick Workflow:**

```vim
1. Space /          # Open grep
2. Type search term
3. Enter on result  # Jump to file
```

**Alternative:**

```vim
Space sg            # Grep (root) - same as Space /
Space sG            # Grep (cwd)
Space sw            # Grep word under cursor
```

#### Search & Replace

**`Space sr`** - Search & replace (grug-far)

Project-wide search and replace with UI.

#### Discover All Keybindings

**`Space sk`** - Search keymaps

Essential for discovering keybindings you forgot! Opens picker with all available keymaps.

#### Other Searches

```vim
Space sh            # Help pages
Space sm            # Marks
Space sc            # Commands
Space sC            # Command history
Space sb            # Buffer search (fuzzy find lines in current buffer)
Space ss            # LSP symbols (document)
Space sS            # LSP symbols (workspace)
```

---

### Code Intelligence (LSP)

Navigate and understand code using Language Server Protocol.

#### Navigation

**Primary:**

```vim
gd                  # Go to definition (MOST USED)
gr                  # Find references
K                   # Hover documentation
```

**Advanced:**

```vim
gI                  # Go to implementation
gy                  # Go to type definition
gD                  # Go to declaration
gK                  # Signature help
```

#### Code Actions

**`Space ca`** - Code action ⭐⭐⭐

The most important LSP keybinding. Provides context-aware actions:

- Quick fixes for errors
- Add missing imports
- Extract to function/variable
- Generate code
- Apply suggestions

**Quick Workflow:**

```vim
1. Cursor on error
2. Space ca         # Open code actions
3. Select fix       # Apply
```

#### Refactoring

**`Space cr`** - Rename symbol (with live preview)

Renames symbol across entire project, updates all references.

**`Space cf`** - Format document

Auto-format current file using configured formatters (prettier, black, stylua, etc.).

**`Space cF`** - Format injected languages

Format code blocks inside markdown, etc.

---

### Vim Motions Mastery

Essential navigation commands for moving efficiently in Neovim. These are
core Vim motions that work everywhere, not LazyVim-specific.

#### Basic Word & Line Movement

**Word Movement (Most Used):**

```vim
w                   # Forward to start of next word
b                   # Backward to start of previous word
e                   # Forward to end of word
ge                  # Backward to end of word
```

**WORD vs word:** Capitalized versions (W/B/E/gE) treat
whitespace-separated text as single units. Use for faster navigation.

**Line Navigation:**

```vim
0                   # Beginning of line
$                   # End of line
^                   # First non-blank character
g_                  # Last non-blank character
```

#### Character Find & Till (f/t Navigation)

**The fastest way to move within a line:**

```vim
f{char}             # Find next {char} (forward)
F{char}             # Find previous {char} (backward)
t{char}             # Till next {char} (stops before)
T{char}             # Till previous {char} (stops after)
;                   # Repeat last f/F/t/T (same direction)
,                   # Repeat last f/F/t/T (opposite direction)
```

**Example:** `df,` deletes from cursor to next comma (inclusive).

#### Text Object Navigation

```vim
(  /  )             # Previous/next sentence
{  /  }             # Previous/next paragraph
[[  /  ]]           # Previous/next section (or '{' in first column)
%                   # Jump to matching bracket/brace/paren
```

#### File Navigation (gg/G)

```vim
gg                  # Go to first line
G                   # Go to last line
{number}gg          # Go to line number (e.g., 42gg)
{number}G           # Same as above (e.g., 42G)
```

**Window positions:**

```vim
H                   # Top of window (High)
M                   # Middle of window
L                   # Bottom of window (Low)
```

#### Scrolling Commands

**Half-Page Scrolling (Most Ergonomic):**

```vim
Ctrl-d              # Scroll down half screen
Ctrl-u              # Scroll up half screen
```

**Full-Page Scrolling:**

```vim
Ctrl-f              # Scroll forward one full screen
Ctrl-b              # Scroll backward one full screen
```

**Line-by-Line (Fine Control):**

```vim
Ctrl-e              # Scroll screen down one line (cursor stays)
Ctrl-y              # Scroll screen up one line (cursor stays)
```

**Screen Repositioning (z-commands):**

```vim
zt                  # Position current line at top
zz                  # Position current line at center
zb                  # Position current line at bottom
```

**Use case:** After jumping to definition with `gd`, use `zz` to center
the code on screen.

#### Search Motions

**Basic Search:**

```vim
/pattern            # Search forward
?pattern            # Search backward
n                   # Next result (same direction)
N                   # Previous result (opposite direction)
```

**Word Under Cursor (Fast!):**

```vim
*                   # Search forward for exact word
#                   # Search backward for exact word
g*                  # Search forward (partial match)
g#                  # Search backward (partial match)
```

**Advanced: Visual Selection of Matches:**

```vim
gn                  # Select next search match (visual mode)
gN                  # Select previous search match
```

**Power combo:** After searching with `*`, use `cgn` to change next
match, then `.` to repeat on other matches!

#### Marks & Jump List

**Setting Marks:**

```vim
m{a-z}              # Set local mark (buffer-specific)
m{A-Z}              # Set global mark (across files)
```

**Jumping to Marks:**

```vim
'{mark}             # Jump to line of mark
`{mark}             # Jump to exact position (line & column)
:marks              # View all marks
```

**Jump List Navigation (Critical for Context Switching):**

```vim
Ctrl-o              # Go to older position in jump list
Ctrl-i              # Go to newer position in jump list
:jumps              # View jump list
```

**Example workflow:**
1. `gd` to jump to definition (adds to jump list)
2. Read code
3. `Ctrl-o` to jump back to where you were

#### Flash Navigation (LazyVim Enhancement)

LazyVim adds Flash.nvim for turbocharged movement:

```vim
s{char}{char}       # Flash: jump to any visible location
S                   # Flash treesitter: jump to functions/classes
```

**Why Flash matters:** Replaces tedious `10j` or repeated `w` with
precise 2-character jumps. Much faster than counting lines.

#### Enhanced LazyVim Behaviors

**Smart j/k for Wrapped Lines:**

LazyVim maps j/k to use `gj/gk` when no count is provided, making
navigation through wrapped text more intuitive.

**Auto-Centered Search:**

The `n` and `N` commands auto-center with `zv` and maintain consistent
direction.

**Window Navigation (Works Everywhere!):**

```vim
Ctrl-h/j/k/l        # Navigate windows (even in terminal insert mode!)
```

---

### Diagnostics & Errors

View and navigate errors/warnings from LSP and linters.

#### View All Errors

**Primary (Recommended):**

**`Space xx`** - Toggle Trouble

Opens Trouble.nvim with ALL diagnostics in your workspace. This is your main diagnostics viewer.

**Quick Workflow:**

```vim
1. Space xx         # Open Trouble
2. j/k              # Navigate errors
3. Enter            # Jump to error location
4. Space ca         # Code action to fix (if available)
```

**Alternative (Buffer Only):**

**`Space xX`** - Toggle Trouble (buffer diagnostics)

Shows diagnostics only for current file.

**Alternative (Fuzzy Search):**

```vim
Space sd            # Document diagnostics (current file)
Space sD            # Workspace diagnostics (all files)
```

#### Navigate While Editing

```vim
]d / [d             # Next/previous diagnostic (any severity)
]e / [e             # Next/previous error only
]w / [w             # Next/previous warning only
Space cd            # Show diagnostic details at cursor
```

#### Other Trouble Views

```vim
Space xL            # Location list (Trouble)
Space xQ            # Quickfix list (Trouble)
]q / [q             # Next/previous trouble item
```

---

### Git Integration

All git operations without leaving Neovim.

#### Primary: LazyGit

**`Space gg`** - Open LazyGit (root directory)

LazyGit is your PRIMARY git interface. Handles all git operations in a beautiful TUI.

**Complete Git Workflow:**

```vim
1. Make code changes
2. Space gg         # Open LazyGit
3. (In LazyGit):
   Space            # Stage files
   a                # Stage all
   c                # Commit (write message, :wq to save)
   P                # Push
   q                # Close LazyGit
4. Continue coding - never left Neovim!
```

**LazyGit Essential Keys:**

```
NAVIGATION
Tab / Shift+Tab     # Switch sections (Files/Branches/Commits/Stash)
j/k                 # Move up/down
Enter               # View details/diff

STAGING
Space               # Stage/unstage file
a                   # Stage all files
d                   # Discard changes

COMMITTING
c                   # Commit (opens editor for message)
A                   # Amend last commit

BRANCHES & REMOTE
P                   # Push to remote
p                   # Pull from remote
o                   # Create new branch
Space (Branches)    # Checkout branch

VIEWING
]c / [c             # Next/prev hunk in diff
x                   # Open command menu
?                   # Show help
q                   # Quit LazyGit
```

**Alternative:**

```vim
Space gG            # LazyGit (cwd instead of root)
```

#### File-Level Git Operations

```vim
Space gb            # Git blame line
Space gB            # Git browse (open in GitHub browser)
Space gY            # Git browse (copy GitHub URL)
Space gf            # Git file history
```

#### Diff & Status

```vim
Space gd            # Git diff (hunks in current file)
Space gD            # Git diff (against origin)
Space gs            # Git status
Space gS            # Git stash list
```

#### Commit & Log

```vim
Space gl            # Git log (root)
Space gL            # Git log (cwd)
Space gc            # Git commits (picker)
```

#### Hunk Navigation

```vim
]h / [h             # Next/previous git hunk
]c / [c             # Next/previous git change (in diff view)
```

---

### Terminal

Use Neovim's integrated Snacks terminal for quick commands. Reserve WezTerm for long-running servers only.

#### Opening Terminals

**Primary (Fastest):**

**`Ctrl+/`** - Toggle terminal (root dir)

Opens Snacks terminal in bottom split, auto-enters insert mode.

**Alternative:**

```vim
Space ft            # Terminal (root dir)
Space fT            # Terminal (cwd)
```

#### Terminal Navigation

#### Understanding Terminal Modes

Neovim terminals have TWO modes you need to understand:

**Terminal-Insert Mode (Default):**

- This is where you type shell commands
- You're "inside" the terminal process
- Even in insert mode, `Ctrl+h/j/k/l` work (LazyVim magic!)
- But you CANNOT scroll with j/k, search with /, or copy with vim motions

**Terminal-Normal Mode (via Esc Esc):**

- Access all vim powers while viewing terminal output
- Scroll with `j/k`, `Ctrl+d/u`, `gg/G`
- Search output with `/pattern`
- Copy text with visual mode + `y`
- View and navigate long outputs
- Press `i` to return to insert mode

**When to Use Terminal-Normal Mode:**

- Reading long test output or logs
- Copying error messages or stack traces
- Searching command output with `/`
- Reviewing previous commands
- Any time you need vim navigation powers

**Why Double-Tap Esc?**

Single Esc might exit programs running in terminal (vim, less, etc.).
Double-tap `Esc Esc` is LazyVim's safe pattern to enter normal mode.

**THE POWER MOVE:**

Even in terminal INSERT mode, you can navigate windows:

```vim
Ctrl+h              # Jump to left window
Ctrl+j              # Jump to window below
Ctrl+k              # Jump to window above
Ctrl+l              # Jump to right window
```

**Workflow Example:**

```vim
1. Coding in editor
2. Ctrl+/           # Open terminal (bottom split)
3. npm test         # Run tests
4. Ctrl+k           # Jump back to editor WITHOUT ESC!
5. Fix code
6. Ctrl+j           # Jump back to terminal
7. Tests auto-rerun
```

**Exiting Terminal Mode:**

```vim
Esc Esc             # Exit to normal mode (double-tap quickly)
i                   # Re-enter insert mode
Ctrl+/              # Hide terminal (toggle)
q                   # Hide terminal (when in normal mode)
```

#### Use Neovim Terminal vs WezTerm

**Use Neovim Terminal (Ctrl+/):**

- Quick commands (git, npm test, build)
- LazyGit (Space gg)
- Test-driven development (watch mode)
- Database queries (:DBUI)
- Any command that completes quickly

**Use WezTerm:**

- Long-running servers (npm run dev)
- Docker containers
- Log tailing
- File watchers
- Multiple independent background processes

---

### Obsidian Note-Taking

Your slipbox vault at `~/obsidian/slipbox` integrated with LazyVim.

#### Daily Notes Workflow

**Primary:**

**`Space ot`** - Open today's daily note

Your most used Obsidian command. Opens or creates today's daily note.

**Quick Workflow:**

```vim
1. Space ot         # Open today's note
2. Start journaling
3. [[ + type        # Auto-complete wiki links
4. # + tag name     # Auto-complete tags
5. Enter on link    # Follow link (smart action)
```

**Other Daily Notes:**

```vim
Space oy            # Yesterday's daily note
Space om            # Tomorrow's daily note
Space od            # Browse all daily notes (picker)
```

#### Note Management

**`Space oo`** - Quick switch to any note

Opens Snacks picker with all notes in your vault. Fuzzy search by title.

**`Space os`** - Search note contents

Grep search across all notes in your vault.

**`Space on`** - Create new note

Prompts for title, creates note with slug-ified filename and frontmatter.

**Other Note Operations:**

```vim
Space of            # Follow link under cursor
Space ob            # Show backlinks (notes linking to current note)
Space ol            # Show links in current note
Space oc            # Table of contents
```

#### Templates & Media

**`Space oT`** - Insert template

Opens picker to select from templates in `templates/` directory.

**`Space op`** - Paste image from clipboard

Pastes image, saves to `assets/imgs/`, inserts markdown link.

**`Space o-`** - Insert checkbox

Adds checkbox `[ ]` to current line. Works on bullet points or plain lines.

**`Space ox`** - Toggle checkbox

Cycles checkbox states: `[ ]` (TODO) → `[x]` (DONE) → `[>]` (FORWARDED) → `[~]` (CANCELLED) → back to `[ ]`

**Note:** Checkboxes display as readable text labels (TODO, DONE, FORWARDED, CANCELLED) in Neovim while maintaining standard markdown syntax in files.

#### Smart Actions (Markdown Files Only)

**`<CR>` (Enter)** - Smart action

Context-aware action based on cursor position:

- On `[[link]]`: Follow link or create note if doesn't exist
- On tag: Show all notes with that tag
- On checkbox: Toggle state
- On heading: Fold/unfold

**Link Navigation:**

```vim
[o / ]o             # Navigate to previous/next link
```

#### Obsidian Features

- **Completion**: `[[` triggers wiki link completion (blink.cmp)
- **Tags**: `#` triggers tag completion
- **Templates**: Daily note template auto-applied
- **Picker**: Snacks picker for all note navigation
- **Backlinks**: Full backlink support
- **Checkboxes**: 4-state cycle with readable text labels
  - `[ ]` → TODO (orange)
  - `[x]` → DONE (cyan)
  - `[>]` → FORWARDED (orange)
  - `[~]` → CANCELLED (red)

---

### Buffer Management

Navigate between open files (buffers).

#### Switch Buffers

**Primary:**

```vim
Shift+H             # Previous buffer (MUSCLE MEMORY)
Shift+L             # Next buffer (MUSCLE MEMORY)
```

**Alternative:**

```vim
Space ,             # Switch buffers (picker)
Space fb            # Buffer list (picker)
[b                  # Previous buffer
]b                  # Next buffer
```

#### Buffer Operations

```vim
Space bd            # Delete buffer (close file)
Space bo            # Delete other buffers
Space bD            # Delete buffer and window
Space bp            # Pin buffer
Space bP            # Delete non-pinned buffers
```

---

### Window & Split Management

Manage editor windows and splits.

#### Window Navigation

**`Ctrl+h/j/k/l`** - Navigate windows (vim-style)

Works in ALL modes, including terminal insert mode!

#### Creating Splits

```vim
Space -             # Split below
Space |             # Split right
Ctrl+w s            # Split horizontal (classic vim)
Ctrl+w v            # Split vertical (classic vim)
```

#### Window Operations

```vim
Space wd            # Delete window (close split)
Space wm            # Toggle maximize/zoom
Ctrl+w o            # Close all other splits
```

#### Window Resizing

```vim
Ctrl+Up             # Increase height
Ctrl+Down           # Decrease height
Ctrl+Left           # Decrease width
Ctrl+Right          # Increase width
```

---

### Completion (blink.cmp + Copilot)

Your setup uses **blink.cmp** (Rust-based, ultra-fast) with GitHub Copilot integration.

#### Completion Navigation

**In completion menu:**

```vim
Tab                 # Accept completion/Copilot suggestion
Ctrl+n              # Next completion
Ctrl+p              # Previous completion
Ctrl+e              # Close completion menu
```

#### Copilot Suggestions

**`Tab`** - Accept Copilot suggestion (via blink.cmp)

**`M-]`** - Move to next Copilot suggestion

**`M-[`** - Move to previous Copilot suggestion

**`Esc`** - Reject Copilot suggestion

#### Completion Sources

Your blink.cmp is configured with:

- LSP (language servers)
- GitHub Copilot (inline suggestions)
- Path completion
- Snippets
- Obsidian wiki links (`[[`)
- SQL (vim-dadbod-completion)

---


debugging, and refactoring.

#### Terminal Navigation

**THE KEY INSIGHT:** Even in terminal INSERT mode,
navigate windows seamlessly:

```vim
Ctrl+h              # Jump to editor (LEFT - 50% of screen)
Ctrl+j/k            # Jump to windows above/below
```

**No Esc needed!** Stay in conversation mode while coding.

**Terminal Modes:**


**TERMINAL-INSERT MODE (Default - Stay Here Most of the Time):**

- No Esc needed for window navigation
- **Primary workflow:** Stay in insert mode, use Ctrl+h/l to navigate

**TERMINAL-NORMAL MODE (For Reading Long Responses):**

- Copy code snippets with visual mode + `y`
- Review conversation history
- Press `i` to return to insert mode



- Scroll without mouse
- Search for specific keywords in responses
- Copy code blocks to paste elsewhere
- Review previous answers

**CRITICAL: Esc Esc Interruption Bug**

with LazyVim's default terminal normal mode escape pattern.

**Best Practice - Avoid the Problem Entirely:**

```vim
# Primary workflow (90% of the time):
2. Use Ctrl+h to jump back to editor (no Esc!)
4. Only enter normal mode when you MUST read/copy long output
```

**When You MUST Enter Normal Mode:**

**Option 1: Use Ctrl-n (Recommended - Configured in Setup)**

```vim
i                   # Return to insert mode
```


**Option 2: Use Esc Esc with Caution**

```vim
Esc Esc             # Default LazyVim escape (may interrupt tasks!)
i                   # Return to insert mode
```


**Terminal Control:**

```vim
Ctrl+n              # Enter normal mode (SAFE - won't interrupt)
Esc Esc             # Enter normal mode (CAUTION - may interrupt)
i                   # Return to insert mode
q                   # Close terminal (when in normal mode)
```


**Slash Commands:**

```vim
/help               # Show all available commands
/rewind             # Undo changes (cancel current operation)
/review             # Code review mode with bug spotting
```

**Navigation:**

```vim
Ctrl+r              # Search command history
Up/Down arrows      # Browse command history
```

#### Automatic Context Awareness


- Current file you're editing
- Text selections in real-time
- Open buffers in workspace
- Diagnostics and errors
- Workspace folder structure

**This is why Neovim integration beats a separate terminal!**

#### Primary Commands







#### Diff Management

**`Space aa`** - Accept diff


**`Space ad`** - Deny diff



```vim
Space am            # Select model (Sonnet/Opus/Haiku)
```


##### Workflow 1: Quick Question

```vim
4. Ctrl+h           # Back to editor (no app switching!)
```

##### Workflow 2: Code Review/Refactor

```vim
1. Visual select code
3. Ask to review/refactor
4. Space aa         # Accept changes (or Space ad to reject)
```

##### Workflow 3: Add Multiple Files

```vim
1. Space e          # Open explorer
2. V on directory   # Select files
5. Ask about codebase
```

##### Workflow 4: Debugging

```vim
1. Hit error
2. Space ab         # Add current buffer
3. Space as         # Send stack trace (visual selection)
4. Space ac         # Ask "Why is this failing?"
```

##### Workflow 5: Multi-File Context

```vim
1. Space e          # Open file explorer
2. V on directory   # Visual select files
5. Ask about architecture
6. Ctrl+h           # Back to editor
```

##### Workflow 6: Pair Programming Flow

```vim
2. Ctrl+h           # Back to editor (left 50%)
3. Write code
5. Ctrl+h           # Fix issues
6. Ctrl+l           # Continue conversation
# No app switching - pure flow state!
```

#### Why Neovim Integration vs Separate Terminal?

**Old flow (WezTerm tab):**

- Context switch between apps (Cmd+Tab)
- Manual file management
- Copy/paste diffs manually
- Lost context when switching

**New flow (Neovim split):**

- ✅ Stay in Neovim 100%
- ✅ Automatic file context
- ✅ Real-time selection awareness
- ✅ Native diff viewer (`Space aa`/`Space ad`)
- ✅ `Ctrl+h`/`Ctrl+l` navigation (no Esc!)
- ✅ Session persists layout

**Configuration:** Right split, 50% width

---

### UI Toggles

Toggle various UI features on/off.

```vim
Space uf            # Toggle auto-format (global)
Space uF            # Toggle auto-format (buffer)
Space ud            # Toggle diagnostics
Space ul            # Toggle line numbers
Space uL            # Toggle relative line numbers
Space uw            # Toggle word wrap
Space uz            # Toggle zen mode
Space uc            # Toggle conceal
Space uh            # Toggle inlay hints
```

---

### Advanced Navigation

#### Flash Navigation

**`s{char}{char}`** - Flash jump

Jump to any visible location by typing 2 characters.
Replaces using arrow keys or `10j`.

**Example:**

```vim
s fo                # Jump to next "fo"
s th                # Jump to next "th"
```

**Other Flash Commands:**

```vim
S                   # Flash treesitter (jump to functions/classes)
r                   # Remote flash (operator-pending mode)
R                   # Treesitter search
```

**Pro Tip:** Use `s` for 90% of in-file navigation.

#### Treesitter Text Objects

Operate on functions and classes using AST-based text objects.

```vim
daf                 # Delete around function
dif                 # Delete inside function
dac                 # Delete around class
dic                 # Delete inside class
vif                 # Visual select inside function
vac                 # Visual select around class
cif                 # Change inside function
```

**Pro Tip:** Combine with operators (d/c/v/y) for powerful editing.

---

### Yank History (Yanky)

Never lose a yank again with persistent yank ring.

#### Cycling Yanks

```vim
y                   # Yank text
p                   # Paste after
P                   # Paste before
]p                  # Cycle to next yank in history
[p                  # Cycle to previous yank in history
```

#### Browse Yank History

**`Space p`** - Open yank history (picker)

View all yanks in a picker, select to paste.

#### Other Paste Commands

```vim
gp                  # Paste after and leave cursor
gP                  # Paste before and leave cursor
```

---

### Todo Comments

Highlight and navigate TODO/FIXME/HACK comments.

#### Todo Navigation

```vim
]t                  # Next todo comment
[t                  # Previous todo comment
```

#### View All Todos

```vim
Space st            # All todos (picker)
Space sT            # TODO/FIX/FIXME only (picker)
Space xt            # All todos (Trouble)
Space xT            # TODO/FIX/FIXME only (Trouble)
```

#### Supported Keywords

```text
TODO: Description
FIXME: Description
HACK: Description
WARN: Description
PERF: Description
NOTE: Description
TEST: Description
```

---

### Debugging (DAP)

Full debugging support with nvim-dap.

#### Breakpoints

```vim
Space db            # Toggle breakpoint
Space dB            # Breakpoint condition
```

#### Debugging Controls

```vim
Space dc            # Continue
Space dC            # Run to cursor
Space di            # Step into
Space do            # Step out
Space dO            # Step over
Space dp            # Pause
Space dt            # Terminate
Space dr            # Toggle REPL
Space dl            # Run last
```

#### Debug Navigation

```vim
Space dj            # Down
Space dk            # Up
Space dg            # Go to line (no execute)
```

#### Debug Views

```vim
Space ds            # Session
Space dw            # Widgets
```

---

### Testing (Neotest)

Run tests from within Neovim.

#### Running Tests

```vim
Space tt            # Run nearest test
Space tT            # Run all tests in file
Space tf            # Run test file
Space tl            # Run last test
```

#### Test Views

```vim
Space ts            # Toggle test summary
Space to            # Toggle test output
Space tO            # Toggle test output panel
Space tw            # Toggle test watch mode
```

---

### Session Management

Auto-save and restore your workspace using persistence.nvim.

#### Session Commands

```vim
Space ql            # Restore last session
Space qs            # Save session
Space qS            # Choose session from list
Space qd            # Don't save current session (disable)
Space qq            # Quit all (auto-saves session)
```

#### How Sessions Work

**Automatic:**

- Sessions auto-save when you quit (`:qa`, `Space qq`)
- Each directory gets its own session
- Dashboard shows "Restore Session" option (press `s`)

**What Gets Saved:**

- All open buffers
- Window layout (splits)
- Cursor positions
- Working directory
- Marks and jumps

**What Doesn't Get Saved:**

- Terminal processes (terminals reopen empty)
- File explorer state
- Unsaved changes (save first!)

**Workflow:**

```vim
Morning:
nvim                # Open in project directory
s (dashboard)       # Press 's' to restore session

Evening:
Space qq            # Quit all (auto-saves session)
```

---

### Dial (Enhanced Increment/Decrement)

Enhanced `Ctrl+a` and `Ctrl+x` that work with more than just numbers.

```vim
Ctrl+a              # Increment: numbers, dates, booleans, hex colors
Ctrl+x              # Decrement: numbers, dates, booleans, hex colors
```

**Works on:**

- Numbers: `42` → `43`
- Dates: `2025-11-10` → `2025-11-11`
- Booleans: `true` → `false`
- Hex colors: `#ff0000` → `#ff0001`

---

### Which-Key Discovery

**Press `Space` and wait 1 second** - Interactive keymap menu appears!

Explore keybindings without memorizing everything:

- `Space c` → See all code actions
- `Space s` → See all search options
- `Space g` → See all git commands
- `Space u` → See all UI toggles

**`Space sk`** - Search all keymaps (picker)

Essential for finding forgotten keybindings!

---

### Other Useful Commands

#### Database (SQL)

**`Space D`** or **`:DBUI`** - Database UI

Open vim-dadbod database client:

- Connect to databases
- Run SQL queries
- See results in Neovim
- SQL autocomplete (via vim-dadbod-completion)

#### REST API Testing

**`Space R`** - REST API testing (Kulala)

HTTP client like Postman, in Neovim:

- Create `.http` files
- Execute requests
- View responses
- Environment variables support

#### Commenting

```vim
gcc                 # Comment line (normal mode)
gc + motion         # Comment motion (e.g., gcap = comment paragraph)
gc (visual)         # Comment selection
```

#### Line Movement

```vim
]e / [e             # Move line down/up (LazyVim default)
```

**Note:** `Alt+j/k` is disabled (Aerospace conflict).

#### Tabs

```vim
Space <tab><tab>    # New tab
Space <tab>d        # Close tab
Space <tab>[        # Previous tab
Space <tab>]        # Next tab
```

#### Other Leader Commands

```vim
Space l             # Lazy plugin manager
Space :             # Command history
Space .             # Repeat last command
```

---

## 2. WezTerm Terminal Multiplexer

WezTerm is for **long-running servers only**.
Use Neovim terminal (Ctrl+/) for everything else.

### WezTerm Leader Key

**`Ctrl+a`** (1 second timeout)

### WezTerm Essential Keymaps

```vim
Ctrl+a → s          # Split pane vertically
Ctrl+a → v          # Split pane horizontally
Ctrl+a → h/j/k/l    # Navigate panes (vim-style)
Ctrl+a → q          # Close current pane
Ctrl+a → z          # Zoom/maximize pane (toggle)
Ctrl+a → t          # New tab
Ctrl+a → [/]        # Previous/next tab
```

### Other Useful Features

```vim
Ctrl+a → b          # Show tab navigator
Ctrl+a → r          # Rename tab
Ctrl+a → w          # Show workspaces
Ctrl+a → Space      # QuickSelect (URLs, paths)
Ctrl+ / Ctrl-       # Font size increase/decrease
Ctrl+0              # Reset font size
```

### Rehoboam (Rust TUI)

Real-time observability TUI for Claude Code agents. Named after Westworld's AI that tracks and predicts every human's path.

**Launch:** `rehoboam` (or `rehoboam --debug`)

```vim
q / Esc             # Quit
j / Down            # Select next agent
k / Up              # Select previous agent
Enter               # Jump to selected agent's WezTerm pane
d                   # Toggle debug mode (shows event log)
? / h               # Toggle help
```

**Features:**
- Real-time activity sparklines per agent
- Agent count in header: `Rehoboam (3 agents: 1 working, 2 idle)`
- Event log (press `d` to toggle)
- Jump to any agent's terminal

**Socket:** `/tmp/rehoboam.sock`
**Logs:** `~/.cache/rehoboam/logs/`

**Install:** `cargo build --release && ./target/release/rehoboam --install`

### Configuration

- Font: JetBrainsMono Nerd Font, size 22
- Color scheme: Tokyo Night
- 10,000 line scrollback
- Unix domain for session persistence

---

## 3. Aerospace Window Manager

Aerospace handles system-level window management
(i3-like tiling for macOS).

### Aerospace Mod Key

**`Alt`** (Option key)

### Aerospace Essential Keymaps

```vim
Alt+h/j/k/l         # Focus window (vim-style)
Alt+Shift+h/j/k/l   # Move window
Alt+b/t/d/m/s/e     # Switch workspace (Browser/Terminal/Dev/Media/Slack/Email)
Alt+Shift+b/t/m/s   # Move window to workspace
Alt+Tab             # Toggle last workspace
Alt+Shift+f         # Toggle fullscreen
Alt+/               # Toggle layout (horizontal/vertical)
Alt+,               # Accordion layout (stacked)
```

### Modal Modes

#### Service Mode (Alt+Space)

```vim
Alt+Space → f       # Toggle floating
Alt+Space → b       # Balance window sizes
Alt+Space → h/j/k/l # Join windows
Alt+Space → -       # Flatten layout (reset)
Alt+Space → Esc     # Exit mode
```

#### Resize Mode (Alt+r)

```vim
Alt+r → h/j/k/l     # Resize by 50px
Alt+r → Shift+h/j/k/l # Fine resize by 10px
Alt+r → b           # Balance sizes
Alt+r → Esc         # Exit mode
```

### Workspace Layout

- **B**: Browser
- **T**: Terminal (WezTerm lives here)
- **D**: Development (Neovim coding)
- **M**: Media
- **S**: Slack/Communication
- **E**: Email

---

## Living in Neovim Workflow

### Morning Startup

```vim
# In WezTerm:
cd ~/project
nvim .

# In Neovim:
s                   # Restore session (dashboard)

# Start working:
Space Space         # Find files
Space e             # Browse structure
Ctrl+/              # Terminal for commands
Space gg            # LazyGit for git
```

### Daily Development Loop

```vim
1. Space Space      # Find file
2. gd / gr          # Navigate code
3. Space ca         # Code actions/fixes
4. Ctrl+/           # Run tests
5. Space gg         # Git commit
6. Repeat
```

### Exploring New Codebase

```vim
1. nvim .           # Open project
2. Space e          # File explorer
3. V on directory   # Select files
7. gd / gr          # Navigate with LSP
```

### Test-Driven Development

```vim
1. Space -          # Split below
2. Ctrl+/           # Terminal in bottom
3. npm run test:watch # Start watcher
4. Ctrl+k           # Jump to code
5. Write test
6. Ctrl+j           # Check result
7. Repeat
```

### Full Git Workflow (Never Leave Neovim)

```vim
1. Make changes
2. Space cf         # Format code
3. :wa              # Save all
4. Space gg         # LazyGit
5. Space (stage)    # Stage files
6. c (commit)       # Write message, :wq
7. P (push)         # Push
8. q                # Close LazyGit
```

### Daily Notes in Obsidian

```vim
1. Space ot         # Today's note
2. Write entry
3. [[ + name        # Link to note
4. Enter on link    # Follow/create
5. Space oc         # TOC when needed
6. :w               # Save
```

---

## Troubleshooting

### "Where do I see all errors?"

```vim
Space xx            # Trouble - shows all diagnostics
Space xX            # Trouble - current buffer only
```

### "How do I find a keybinding?"

```vim
Space sk            # Search all keymaps (picker)
Space               # Wait 1 second (Which-Key popup)
```

### "Terminal not responding?"

```vim
Esc Esc             # Enter normal mode (scroll/search/copy)
i                   # Enter insert mode (type commands)
Ctrl+/              # Toggle terminal (hide/show)
```

**Understanding terminal modes:**

- **Insert mode** (default): Type commands, send to shell
- **Normal mode** (`Esc Esc`): Vim navigation, search, copy
- `Ctrl+h/j/k/l` work in BOTH modes for window navigation

If keys aren't working as expected, check which mode you're in!

### "Lost my yanked text?"

```vim
Space p             # Yank history (picker)
]p / [p             # Cycle yank history
```


```vim
:messages           # View logs
```

### "Session not restoring?"

```vim
Space ql            # Manually restore last session
Space qS            # Choose from session list
```

---

## Summary Statistics

**Your Complete Setup:**

- **Neovim**: 0.11.4 with LazyVim
- **Plugins**: 59 installed
- **LazyVim Extras**: 25 enabled
- **Completion**: blink.cmp (Rust-based, ultra-fast)
- **Picker**: Snacks picker (NOT Telescope)
- **File Explorer**: Snacks explorer
- **Terminal**: Snacks terminal
- **Theme**: Tokyo Night (night variant)
- **Notes**: Obsidian.nvim (slipbox vault)

**Workflow Distribution:**

- **WezTerm**: 5% (dev servers only)

**Philosophy:**

- Minimal custom config (6 keybinding deletions)
- Trust LazyVim defaults
- Living in Neovim for everything

**Power Features:**

- Snacks suite (picker, explorer, terminal, dashboard)
- blink.cmp completion (ultra-fast)
- Obsidian.nvim (daily notes)
- LazyGit in Neovim (complete git workflow)
- Session persistence (instant context restoration)

---

## Configuration Files

- **Neovim**: `~/.config/nvim/`
- **WezTerm**: `~/.config/wezterm/wezterm.lua`
- **Aerospace**: `~/.config/aerospace/aerospace.toml`
- **Obsidian**: `~/obsidian/slipbox/`

All managed via GNU Stow from `~/dotfiles`.

---

**Built with:** LazyVim (60 plugins, 27 extras), Snacks.nvim suite,
and Tokyo Night.
