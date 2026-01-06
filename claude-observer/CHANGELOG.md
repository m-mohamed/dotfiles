# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Initial project structure
- Unix socket listener for hook events
- Real-time TUI with ratatui
- Agent status display with progress bars
- Activity sparklines
- Event log
- Tokyo Night color scheme
- CLI with clap (--help, --version, --socket)

## [0.1.0] - Unreleased

### Added
- First release
- Core architecture: hooks -> socket -> daemon -> TUI
- Support for all Claude Code hook events
- Keyboard navigation (j/k, q, Enter)
- Jump to agent via wezterm cli

[Unreleased]: https://github.com/m-mohamed/dotfiles/compare/claude-observer-v0.1.0...HEAD
[0.1.0]: https://github.com/m-mohamed/dotfiles/releases/tag/claude-observer-v0.1.0
