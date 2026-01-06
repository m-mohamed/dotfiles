# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.6.3] - 2026-01-06

### Changed
- Rust TUI tick() now follows ratatui async-template best practice (events = data, ticks = render only)
- Sparklines now show consistent bar heights (no jumping between tick and event values)

## [0.6.2] - 2025-01-06

### Fixed
- JSON escaping vulnerability in send-event.sh - now uses `jq` for proper escaping
- Python code injection in send-event.sh - JSON now passed via stdin
- Silent WEZTERM_PANE failure - now logs to debug.log
- Aggressive cache clearing in WezTerm dashboard that defeated LRU
- Unbounded socket task spawning in Rust TUI - added 100 connection limit
- Socket accept error loop in Rust TUI - added exponential backoff

### Added
- SubagentStop hook for Task tool completion (now 10 hooks total)
- JSON schema validation in WezTerm plugin (rejects invalid status values)
- Socket timeout (500ms) in send-event.sh to prevent hanging

### Changed
- statusbar.lua documented as intentionally disabled

## [0.6.1] - 2025-01-04

### Changed
- Obsidian vault path updated to lowercase `~/obsidian/slipbox`
- KEYMAPS.md documentation updated to reflect lowercase vault name

## [0.6.0] - 2025-01-04

### Fixed
- Claude Code hooks now use file-based status communication (OSC 1337 escape sequences don't work from detached hook subprocesses)
- WezTerm Agent Dashboard now correctly displays agent status icons (🤖 running, 🔐 blocked, 🔔 waiting, ⏸️ idle)
- Tab titles now show agent status with elapsed time

### Added
- File-based Claude status tracking at `~/.cache/claude-status/pane-{id}.json`
- WezTerm reads status files every 100ms for near-instant updates
- Automatic cleanup of stale status files older than 1 hour
- `wez-nuke` now cleans up Claude status files

### Changed
- Claude Code hooks write JSON files instead of OSC escape sequences
- WezTerm `format-tab-title` and `update-right-status` read from files instead of user vars
- `get_agents()` function now uses file-based status detection

## [0.5.0] - 2025-01-04

### Fixed
- `wez-nuke` now uses AppleScript to gracefully quit WezTerm when run from inside
- `wez-nuke` now cleans stale log files (`wezterm-gui-log-*.txt`, `wezterm-log-*.txt`)
- `Ctrl+A Shift+X` now properly quits WezTerm using `QuitApplication` action
- Claude hooks now check for `WEZTERM_PANE` before activating pane
- Removed emojis from terminal-notifier titles (prevents encoding issues)

### Changed
- `wez-nuke` is now the primary command, `wez-reset` is an alias

## [0.4.0] - 2025-01-04

### Added
- Enhanced Agent Dashboard with priority sorting (blocked → waiting → running → idle)
- Antigravity-style agent statuses: idle (⏸️), running (🤖), blocked (🔐), waiting (🔔)
- Colored status indicators in tabs, status bar, and Agent Dashboard (Tokyo Night)
- Elapsed time display for running/blocked/waiting agents
- Visual separators in Agent Dashboard grouping agents by status
- Background highlighting for attention-needed agents
- `Ctrl+A N` keyboard shortcut to jump to next blocked/waiting agent
- Claude Code hooks: SessionStart, PermissionRequest (new blocked status)

### Changed
- Tab titles now use `wezterm.format()` for colored text
- Status bar shows colored agent counts by status
- Agent Dashboard title shows summary count

## [0.3.0] - 2025-01-03

### Added
- Shell aliases: `cc` (claude), `td` (tmux detach)
- GitHub CLI credential helper for git authentication

## [0.2.0] - 2025-01-03

### Added
- Multi-agent notification system for WezTerm workspaces
- terminal-notifier integration with Claude Code hooks
- WezTerm bell-to-toast handler for agent status
- WezTerm tab titles show agent state icons (🤖 running, ✅ done, 🔔 waiting)
- WezTerm status bar shows agent summary count
- tmux configuration for mobile sessions via Termius/SSH
- Mobile workflow aliases: mc, tn, ta, tl, tk, ts
- Tailscale for remote access to development environment
- Multi-agent workflow documentation in README
- Claude Code user settings as stow package (`claude/.claude/settings.json`)

### Changed
- WezTerm status bar enhanced with agent tracking
- Claude Code hooks now set WezTerm user vars for visual state
- install.sh now stows claude and tmux packages

## [0.1.0] - 2025-01-02

### Added
- ZSH configuration with Antidote plugin manager and <100ms startup
- Neovim (LazyVim) with Tokyo Night theme and AI integrations
- WezTerm terminal with Unix domain sessions and custom keybindings
- Aerospace tiling window manager with vim-style navigation
- Karabiner home row mods (ASDF/JKL; as modifiers)
- Sketchybar custom menu bar with system stats
- Starship cross-shell prompt
- Modern CLI tools: eza, bat, fzf, ripgrep, fd, delta, zoxide
- Comprehensive documentation (GUIDE.md, KEYMAPS.md, TOOLS.md)
- Obsidian.nvim integration for note-taking
- Mole utility for Mac cleanup
- Delta git pager with Tokyo Night theme

### Changed
- Modernized dev stack: Bun + Biome (replacing Node/pnpm)
- Python tooling: UV + Ruff + Basedpyright
- WezTerm leader key to Ctrl+a (tmux/screen standard)
- Shell startup optimized from 531ms to ~100ms

### Fixed
- macOS Alt key behavior for Aerospace integration
- Keymap conflicts between LazyVim and Aerospace
- CI pipeline for Apple Silicon
- Installation script error handling

### Removed
- NVM and pnpm (replaced by Bun)
- Docker Desktop (using OrbStack instead)
