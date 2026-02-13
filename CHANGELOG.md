# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).
## [0.1.0] - 2026-02-13

### Added

- Add release automation with git-cliff
- Add workflow aliases and sprites-rs project
- Migrate from WezTerm to Ghostty + Tmux
- MacOS dotfiles with GNU Stow

### Changed

- Reset versioning to 0.0.0
- Update project paths and aliases for current directory structure
- Release v1.1.0 (#1)
- Remove termius cask (broken CDN)
- Remove telegram cask (broken CDN)
- Comprehensive dotfiles audit and fixes
- Replace JSON config with Git auto-discovery
- Remove Anthropic Ralph plugin (using Rehoboam's implementation)
- Remove all WezTerm remnants, polish Ghostty + Tmux

### Documentation

- Sync documentation with recent codebase changes
- Simplify README and remove verbose documentation
- Simplify changelog for v1.0.0 release

### Fixed

- Handle missing previous version in cliff footer
- Use --tag flag for release notes generation
- Move compdef calls after compinit
- Remove .zprofile symlink check (package removed)
[0.1.0]: https://github.com/m-mohamed/dotfiles/releases/tag/v0.1.0

