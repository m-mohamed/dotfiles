# Changelog

Format: [Keep a Changelog](https://keepachangelog.com/en/1.1.0/)
Versioning: [Semantic Versioning](https://semver.org/spec/v2.0.0.html)

## [Unreleased]

### Added
- Workflow aliases and sprites-rs project

### Fixed
- Move compdef calls after compinit for correct ZSH completion setup
- Remove .zprofile symlink check from CI (package removed)

### Changed
- Migrate from WezTerm to Ghostty + Tmux
- Replace tmux-boot JSON config with Git auto-discovery
- Comprehensive dotfiles audit and fixes
- Simplify README and remove verbose documentation

### Removed
- WezTerm remnants (fully replaced by Ghostty + Tmux)
- Termius cask (broken CDN)
- Telegram cask (broken CDN)
- Anthropic Ralph plugin (replaced by Rehoboam)

## [1.0.0] - 2026-01-08

### Added
- ZSH with Antidote, <100ms startup
- Neovim (LazyVim) with Tokyo Night theme
- Ghostty terminal + Tmux session management
- Aerospace tiling window manager
- Sketchybar custom menu bar
- Modern CLI tools (eza, bat, fd, rg, delta)
- Claude Code hooks for rehoboam
- Comprehensive documentation

Note: Pre-1.0 changelog entries were not tracked. See git tags for earlier release history.

[1.0.0]: https://github.com/m-mohamed/dotfiles/releases/tag/v1.0.0
