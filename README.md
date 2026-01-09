# Dotfiles

Modern macOS development environment with <100ms shell startup, optimized for performance and consistency.

## Quick Start

```bash
git clone https://github.com/m-mohamed/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
exec zsh
```

## What's Inside

- **Shell**: ZSH with Antidote plugin manager
- **Terminal**: WezTerm with JetBrains Mono Nerd Font
- **Editor**: Neovim (LazyVim)
- **Window Manager**: Aerospace (tiling)
- **Status Bar**: Sketchybar
- **Prompt**: Starship
- **Keyboard**: Karabiner (Home Row Mods)
- **Modern CLI**: eza, bat, fzf, ripgrep, fd, delta, zoxide, direnv, tldr

## Features

- ⚡ **<100ms startup** - Optimized ZSH with static plugin loading
- 🎨 **Tokyo Night theme** - Consistent colors everywhere
- ⌨️ **Pure vi mode** - No Emacs shortcuts, visual cursor feedback
- 🐟 **Fish-like suggestions** - Smart autosuggestions from history
- 🎯 **Syntax highlighting** - Color-coded commands
- 🔍 **Fuzzy search** - fzf integration (Ctrl+R, Ctrl+T, Alt+C)

## Multi-Agent Workflow

This setup supports running multiple Claude Code instances across WezTerm workspaces.

### Desktop (WezTerm)

- Multiple workspaces with Claude Code + Neovim tabs in each
- Tab titles show agent state: 🤖 running, ✅ done, 🔔 waiting
- Status bar shows agent summary: `🤖2 🔔1 ✅1`
- Notifications via terminal-notifier when agents complete
- Click notification → jumps to correct pane

### Mobile (Tailscale + Termius + tmux)

- SSH via Tailscale VPN (works on cellular)
- tmux sessions per project (WezTerm GUI doesn't work over SSH)
- Aliases: `mc`, `tn`, `ta`, `tl`, `tk`, `ts`

```bash
# From iPhone via Termius
tn fantasy           # New session for project
cd ~/fantasy-agent && claude
# Ctrl+a d to detach

ta fantasy           # Reattach later
tl                   # List sessions
```

## Design Decisions & Opinions

⚠️ **This repo makes opinionated choices that may not match your preferences:**

**Pure Vi Mode** - ALL Emacs bindings disabled (no Ctrl+A/E/K/U). Most users prefer hybrid mode. We chose pure vi for muscle memory consistency across shell, Vim, and all environments.

**Minimal Plugins** - Only 4 plugins (syntax-highlighting, autosuggestions, completions, history-substring-search). Community standard is 10-20 plugins. We chose minimal for maximum performance (<100ms startup).

**No Oh-My-Zsh** - Pure Antidote with static loading. Deliberate performance choice: 800ms → 85ms startup (10x faster).

Want different patterns? These principles (XDG compliance, static loading, performance focus) are solid even if specific choices differ. Fork and adapt!

## Installation

### Automated (Recommended)

```bash
git clone https://github.com/m-mohamed/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install.sh
```

The script will:
1. Install/verify Homebrew
2. Install all dependencies from Brewfile
3. Create XDG directories
4. Stow all configuration files
5. Migrate existing ZSH history
6. Install bat Tokyo Night theme

### Manual

```bash
# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install dependencies
cd ~/dotfiles
brew bundle install

# Set up API keys (optional)
cp zsh/.config/zsh/modules/00-env-secrets.zsh.example \
   zsh/.config/zsh/modules/00-env-secrets.zsh
nvim zsh/.config/zsh/modules/00-env-secrets.zsh

# Deploy configs
stow aerospace borders claude claude-hooks dot-gitconfig dot-zprofile dot-zshenv \
     gh git karabiner nvim scripts sketchybar ssh starship tmux wezterm zsh

# Start new shell
exec zsh
```

## Troubleshooting

**Slow startup?**
```bash
time zsh -i -c exit  # Should be <100ms
./scripts/benchmark.sh  # Detailed performance analysis
```

**Plugins not loading?**
```bash
antidote list && antidote update
```

**Completions broken?**
```bash
rm ~/.cache/zsh/.zcompdump* && exec zsh
```

**Command not found: brew** (WezTerm domains)
```bash
# Already fixed in .zshenv, but if you see this:
source ~/.zshenv
```

## Uninstall

```bash
cd ~/dotfiles
./uninstall.sh
```

Safely removes all symlinks, restores backups, and cleans generated files.

## Documentation

📚 **[Read the Comprehensive Guide →](docs/GUIDE.md)**

⌨️ **[Essential Keymaps Cheat Sheet →](docs/KEYMAPS.md)**

The GUIDE.md contains in-depth documentation (1,800+ lines) covering:
- Configuration architecture (XDG, shell init order, module system)
- Technology choices & alternatives (why each tool was chosen)
- Best practices (secrets, reproducibility, maintenance)
- Design deep dives (pure vi mode, Tokyo Night, Home Row Mods)
- Troubleshooting (diagnostics, common issues, solutions)
- Learning path (week-by-week progression)

The KEYMAPS.md is your 80/20 quick reference for daily workflows:
- WezTerm terminal multiplexer keybinds
- Neovim/LazyVim essential shortcuts
- Aerospace window manager navigation
- Common workflow patterns and tips

## Performance

Measured on 2025 M3 Mac:
- Shell startup: **85ms** (target: <100ms) ✅
- Plugin load: 22ms (4 plugins)
- Completion init: 18ms (with caching)

Run your own benchmark:
```bash
./scripts/benchmark.sh
```

## CI Testing

GitHub Actions automatically tests installation on macOS 14 (ARM64) on every push and weekly.

**What's tested:**
- Package installation verification
- Symlink creation (stow)
- Shell loading without errors
- Alias/function availability
- Tool execution tests
- Startup time benchmarking

**GUI packages skipped in CI** (headless environment):
- `borders` - Window borders (requires GUI)
- `sketchybar` - Menu bar (requires GUI)
- `wezterm` - Terminal emulator (requires GUI)
- `aerospace` - Window manager (requires GUI)
- `karabiner-elements` - Keyboard customization (requires GUI)

These packages install normally on local machines but cannot be tested in headless CI runners.

## Key Bindings

### Vi Mode
- `jk` - Escape to command mode
- Cursor changes: beam (insert) → block (command)

### fzf
- `Ctrl+R` - Search command history
- `Ctrl+T` - Search files
- `Alt+C` - Search directories

## Secrets Management

API keys managed via template system:
1. Copy: `00-env-secrets.zsh.example` → `00-env-secrets.zsh`
2. Edit with your actual keys
3. File is gitignored automatically

Supports: OpenAI, Anthropic, DeepSeek, Gemini, Groq, Twitter, etc.

## Documentation

- [GUIDE.md](docs/GUIDE.md) - Complete architecture guide
- [KEYMAPS.md](docs/KEYMAPS.md) - All keybindings
- [TOOLS.md](docs/TOOLS.md) - Tool configuration reference
- [CLAUDE.md](CLAUDE.md) - AI assistant instructions

## License

MIT - Feel free to use, modify, and share.

---

**Built with:** ZSH, Antidote, Stow, Tokyo Night, WezTerm, Aerospace, Karabiner, Neovim, Bun, and love for fast shells.
