# Dotfiles

macOS development environment with <100ms shell startup.

## Install

```bash
git clone https://github.com/m-mohamed/dotfiles.git ~/dotfiles
cd ~/dotfiles && ./install.sh
exec zsh
```

## What's Inside

| Tool | Purpose |
|------|---------|
| ZSH + Antidote | Shell with 4 essential plugins |
| WezTerm | GPU-accelerated terminal |
| Neovim (LazyVim) | Editor with Tokyo Night theme |
| Aerospace | Tiling window manager |
| Starship | Fast prompt |
| Karabiner | Home row mods |

## Keybindings

See [docs/KEYMAPS.md](docs/KEYMAPS.md) for all shortcuts.

**Quick reference:**
- `jk` - Escape to vi command mode
- `Ctrl+R` - Search history (fzf)
- `Alt+h/j/k/l` - Navigate windows (Aerospace)
- `Ctrl+a` then `h/j/k/l` - Navigate panes (WezTerm)

## Structure

```
dotfiles/
├── zsh/          # Shell config (<100ms startup)
├── nvim/         # LazyVim setup
├── wezterm/      # Terminal config
├── aerospace/    # Window manager
└── ...           # Other tools
```

Each directory is a [GNU Stow](https://www.gnu.org/software/stow/) package.

## Uninstall

```bash
./uninstall.sh
```

## License

MIT
