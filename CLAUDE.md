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
05-tools.zsh        # Tool integrations (zoxide, starship)
06-plugins.zsh      # Antidote static plugin loading
07-modern-tools.zsh # Modern CLI (eza, bat, fzf, ripgrep)
```

### Shell Init Order
- `.zshenv` (ALL shells): XDG vars, Homebrew PATH, ZDOTDIR
- `.zprofile` (login only): OrbStack init
- `.zshrc` (interactive): Sources numbered modules

**Critical**: Homebrew must be in `.zshenv` for non-login shells (e.g., tmux, scripts).

### Performance Optimizations
- **Static plugin loading**: Plugins regenerate only when `.zsh_plugins.txt` changes
- **Completion caching**: `compinit` caches for 24 hours
- **Minimal plugins**: 4 essential plugins (zsh-syntax-highlighting, zsh-autosuggestions, zsh-completions, zsh-history-substring-search)
- **Fast runtimes**: Bun for JS tooling, fnm for Node.js version management

## Claude Code Configuration

This dotfiles repo manages user-level Claude Code settings via the `claude` stow package.

### Configuration Scopes

| Scope | File | Purpose | In Dotfiles? |
|-------|------|---------|--------------|
| **User** | `~/.claude/settings.json` | Personal defaults (all projects) | Yes |
| **Project** | `.claude/settings.json` | Team-shared project settings | No (per-repo) |
| **Local** | `.claude/settings.local.json` | Machine-specific overrides | No (gitignored) |
| **MCP (User)** | `~/.claude.json` | User-level MCPs + OAuth | No (has secrets) |
| **MCP (Project)** | `.mcp.json` | Project-specific MCPs | No (per-repo) |

### What's in Dotfiles

The `claude/.claude/settings.json` file contains:
- **Plugins**: `rust-analyzer-lsp` and `clangd-lsp` (official Claude plugins)
- **Settings**: Always-thinking mode enabled

### Rehoboam Integration

Real-time TUI for monitoring Claude Code agents via Unix socket.

**Install:**
```bash
cargo install --git https://github.com/m-mohamed/rehoboam
```

**Launch:** `rehoboam` (or `--debug` for event log)

- Status indicators: 🤖 (working), 🔔 (attention), ⏸️ (idle), 🔄 (compacting)
- Socket: `/tmp/rehoboam.sock`
- Desktop notifications on permission requests

### Per-Project MCPs

MCP servers stay in each project's `.mcp.json` because:
- Different Supabase project refs per app
- Project-specific integrations (Sentry, PostHog, etc.)
- Team members share project MCPs via version control

## Further Reading

For detailed documentation, see:
- [docs/GUIDE.md](docs/GUIDE.md) - Complete architecture guide
- [docs/KEYMAPS.md](docs/KEYMAPS.md) - All keybindings
- [docs/TOOLS.md](docs/TOOLS.md) - Tool configuration reference

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

**Note:** The module glob `0[0-9]-*.zsh` only matches modules 00-09 (max 10 modules).

## Key Design Decisions

- **Pure vi mode**: No Emacs bindings (Ctrl+A/E/K/U disabled)
- **XDG compliance**: All configs in `~/.config/`, data in `~/.local/share/`
- **Tokyo Night theme**: Consistent colors across all tools
- **Static Antidote loading**: 10x faster than Oh-My-Zsh

## Git Commit Standards

**Local**: Work-in-progress commits can be messy.

**Before pushing to main**: Must be clean.

Follow [Conventional Commits](https://www.conventionalcommits.org/):

```
<type>(<scope>): <description>

[optional body]
```

**Types:** `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `chore`

**Rules:**
- Subject line max 50 chars
- No version numbers in scope
- No implementation details in message
- No AI branding or co-authored-by lines
- Squash WIP commits before push
- Use imperative mood ("add" not "added")


<!-- BEGIN SHARED: Modern CLI Tools -->
## Modern CLI Tools

This environment uses modern Rust/Go CLI tools. **Always prefer these over legacy commands.**

### File Operations
| Task | Use this | NOT this |
|------|----------|----------|
| List files | `eza --icons --git` | `ls` |
| Tree view | `eza --tree --level=2` | `tree` |
| Read files | `bat` or Read tool | `cat` |
| Find files | `fd <pattern>` | `find` |
| Disk usage | `dust` | `du` |

### Search & Text
| Task | Use this | NOT this |
|------|----------|----------|
| Search content | `rg <pattern>` | `grep` |
| JSON processing | `jq` | manual parsing |

### Git & Dev
| Task | Use this | NOT this |
|------|----------|----------|
| Git diffs | `delta` (auto via git) | `diff` |
| Code stats | `tokei` | `cloc`, `wc -l` |
| Benchmarks | `hyperfine '<cmd>'` | `time` |

### System Info
| Task | Use this | NOT this |
|------|----------|----------|
| Process list | `procs` | `ps` |
| Man pages | `tldr <cmd>` | `man` |

### DO NOT use
- `z` or `zoxide` — shell function, broken in Claude Code
- `cd` with relative paths — use absolute paths
- Aliases — not loaded in Bash tool
- `fzf` — interactive, requires human input
- `lazygit`, `lazydocker`, `btop` — TUI tools for humans, use `git`/`docker`/`procs` instead
- `nvm` — use fnm or Bun instead

### Useful Patterns
```bash
# Search with context
rg "pattern" -C 3

# Disk usage of current dir
dust -d 1

# Find processes by name
procs claude

# Benchmark a command
hyperfine 'fd -e rs' 'find . -name "*.rs"'

# Code statistics
tokei --sort code

# Pretty JSON
echo '{"key":"value"}' | jq .
```
<!-- END SHARED: Modern CLI Tools -->
