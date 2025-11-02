# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-01-02

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
