# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).
## [1.1.0] - 2026-02-12

### Added

- Add release automation with git-cliff
- Add workflow aliases and sprites-rs project
- Migrate from WezTerm to Ghostty + Tmux

### Changed

- Remove termius cask (broken CDN)
- Remove telegram cask (broken CDN)
- Comprehensive dotfiles audit and fixes
- Replace JSON config with Git auto-discovery
- Remove Anthropic Ralph plugin (using Rehoboam's implementation)
- Remove all WezTerm remnants, polish Ghostty + Tmux

### Documentation

- Sync documentation with recent codebase changes
- Simplify README and remove verbose documentation

### Fixed

- Move compdef calls after compinit
- Remove .zprofile symlink check (package removed)
## [1.0.0] - 2026-01-09

### Added

- MacOS dotfiles with GNU Stow

### Documentation

- Simplify changelog for v1.0.0 release
[1.1.0]: https://github.com/m-mohamed/dotfiles/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/m-mohamed/dotfiles/compare/v0.6.3...v1.0.0

