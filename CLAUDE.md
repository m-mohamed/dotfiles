# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a macOS dotfiles repository using GNU Stow for symlink management. Target: <100ms shell startup with ZSH, Antidote plugin manager, and modern Rust-based CLI tools.

## Key Commands

```bash
# Installation
./install.sh           # Full installation (Homebrew, packages, stow, setup)
./uninstall.sh         # Remove all symlinks and restore backups

# Stow operations (from ~/dotfiles)
stow -R zsh            # Re-stow a package (after changes)
stow -D zsh            # Unstow a package

# Shell testing
time zsh -i -c exit    # Benchmark startup (target <100ms)
./scripts/benchmark.sh # Detailed performance analysis

# Package management
brew bundle install    # Install all Brewfile packages
brew bundle cleanup    # Preview packages not in Brewfile
brew bundle cleanup --force  # Remove packages not in Brewfile

# Plugin management
antidote list          # List installed plugins
antidote update        # Update all plugins
rm ~/.config/zsh/.zsh_plugins.zsh && exec zsh  # Force plugin regeneration
```

## Architecture

### Directory Structure
Each top-level directory is a stow package that mirrors the target structure:
- `zsh/.config/zsh/` → `~/.config/zsh/`
- `nvim/.config/nvim/` → `~/.config/nvim/`
- `dot-*` packages (e.g., `dot-zshenv`) create files directly in `$HOME`

### ZSH Module System
Modules in `zsh/.config/zsh/modules/` load in numeric order:
```
00-env-secrets.zsh  # API keys (gitignored, copy from .example)
00-env.zsh          # Environment variables
01-path.zsh         # PATH modifications
02-options.zsh      # Shell options, history, completions
03-aliases.zsh      # Command aliases
04-keybindings.zsh  # Vi mode with cursor shapes
05-tools.zsh        # Tool integrations (nvm lazy-load, zoxide, starship)
06-plugins.zsh      # Antidote static plugin loading
07-modern-tools.zsh # Modern CLI (eza, bat, fzf, ripgrep)
```

### Shell Init Order
- `.zshenv` (ALL shells): XDG vars, Homebrew PATH, ZDOTDIR
- `.zprofile` (login only): OrbStack init
- `.zshrc` (interactive): Sources numbered modules

**Critical**: Homebrew must be in `.zshenv` for WezTerm Unix domains (non-login shells).

### Performance Optimizations
- **Static plugin loading**: Plugins regenerate only when `.zsh_plugins.txt` changes
- **Completion caching**: `compinit` caches for 24 hours
- **NVM lazy loading**: Loads on first `nvm` call (saves ~200ms)
- **Minimal plugins**: Only 4 essential plugins

## Configuration Patterns

### Secrets Management
```bash
# Template exists, real file is gitignored
cp zsh/.config/zsh/modules/00-env-secrets.zsh.example \
   zsh/.config/zsh/modules/00-env-secrets.zsh
# Edit with actual API keys
```

### Adding New Packages
1. Add to `Brewfile` with comment
2. Run `brew bundle install`
3. Commit Brewfile change

### Adding New ZSH Configuration
Create numbered module in `zsh/.config/zsh/modules/` (e.g., `08-custom.zsh`).

## Key Design Decisions

- **Pure vi mode**: No Emacs bindings (Ctrl+A/E/K/U disabled)
- **XDG compliance**: All configs in `~/.config/`, data in `~/.local/share/`
- **Tokyo Night theme**: Consistent colors across all tools
- **Static Antidote loading**: 10x faster than Oh-My-Zsh
