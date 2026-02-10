# Brewfile - Dependency Management for Dotfiles
# Install all dependencies: brew bundle install

# ══════════════════════════════════════════════════════════════════════
# Taps
# ══════════════════════════════════════════════════════════════════════
tap "DomT4/autoupdate"           # For brew-autoupdate (automated maintenance)
tap "FelixKratz/formulae"       # For borders, sketchybar
tap "nikitabobko/tap"            # For aerospace
tap "ngrok/ngrok"                # For ngrok cask
tap "oven-sh/bun"                # For bun JavaScript runtime
tap "supabase/tap"               # For supabase CLI
tap "stripe/stripe-cli"          # For stripe CLI
tap "joncrangle/tap"             # For sketchybar-system-stats
tap "tw93/tap"                   # For mole (Mac cleanup utility)

# ══════════════════════════════════════════════════════════════════════
# Core Shell & Terminal
# ══════════════════════════════════════════════════════════════════════
brew "stow"                      # Symlink management
brew "zsh"                       # Shell (keep updated)
brew "starship"                  # Cross-shell prompt
brew "tmux"                      # Terminal multiplexer (mobile sessions via SSH)
cask "ghostty"                   # Fast native terminal (display layer for tmux)

# ══════════════════════════════════════════════════════════════════════
# Window Management & Desktop
# ══════════════════════════════════════════════════════════════════════
cask "aerospace"                 # i3-like tiling window manager
brew "borders"                   # JankyBorders - window borders
brew "sketchybar"                # Custom macOS menu bar
cask "karabiner-elements"        # Keyboard customization

# ══════════════════════════════════════════════════════════════════════
# Editor
# ══════════════════════════════════════════════════════════════════════
brew "neovim"                    # Hyperextensible Vim-based editor

# ══════════════════════════════════════════════════════════════════════
# Modern CLI Tools (Rust-based, Fast)
# ══════════════════════════════════════════════════════════════════════
brew "eza"                       # Modern ls (exa fork, maintained)
brew "bat"                       # Cat with syntax highlighting
brew "ripgrep"                   # Fast grep (rg)
brew "fd"                        # Fast find
brew "fzf"                       # Fuzzy finder
brew "zoxide"                    # Smart cd (shell function, not for Claude Code)
brew "delta"                     # Better git diffs
brew "dust"                      # Disk usage visualizer (du replacement)
brew "procs"                     # Process viewer (ps replacement)
brew "tokei"                     # Code statistics (fast cloc)
brew "hyperfine"                 # CLI benchmarking tool
brew "btop"                      # Process monitor (htop replacement)
brew "direnv"                    # Load/unload env vars by directory
brew "tldr"                      # Simplified man pages
brew "jq"                        # JSON processor
brew "wget"                      # Internet file retriever
brew "gum"                       # Glamorous shell scripts (tmux-boot UI)

# ══════════════════════════════════════════════════════════════════════
# System Utilities
# ══════════════════════════════════════════════════════════════════════
brew "mole"                      # Deep clean and optimize Mac (cache, logs, apps)
brew "terminal-notifier"         # macOS notifications from terminal (Claude Code hooks)
brew "tailscale"                 # Private network CLI for remote access
cask "tailscale"                 # Tailscale GUI app (menu bar)

# ══════════════════════════════════════════════════════════════════════
# Rust Development
# ══════════════════════════════════════════════════════════════════════
brew "rustup"                    # Rust toolchain manager (includes cargo, rustc, rustfmt, clippy)
brew "rust-analyzer"             # Rust Language Server Protocol (LSP)
brew "bacon"                     # Background Rust code checker (better than cargo-watch)
brew "sccache"                   # Shared compilation cache for faster builds
# Rehoboam - Claude Code agent TUI: cargo install --git https://github.com/m-mohamed/rehoboam

# ══════════════════════════════════════════════════════════════════════
# Development Tools
# ══════════════════════════════════════════════════════════════════════
brew "git"                       # Version control
brew "gh"                        # GitHub CLI
brew "lazygit"                   # Terminal UI for git
brew "lazydocker"                # Terminal UI for docker
brew "uv"                        # Python package installer and resolver
brew "ruff"                      # Fast Python linter/formatter
brew "oven-sh/bun/bun"           # Fast JavaScript runtime
brew "fnm"                       # Fast Node Manager (Rust-based nvm alternative)
brew "pnpm"                      # Fast, disk-efficient package manager
brew "biome"                     # Fast TypeScript/JavaScript linter and formatter
brew "supabase/tap/supabase"     # Supabase CLI for local development
brew "stripe/stripe-cli/stripe"  # Stripe CLI for API testing
brew "joncrangle/tap/sketchybar-system-stats"  # System stats for Sketchybar

# ══════════════════════════════════════════════════════════════════════
# Applications & Services
# ══════════════════════════════════════════════════════════════════════
cask "orbstack"                  # Docker desktop alternative (faster, lighter)
cask "raycast"                   # Spotlight alternative with extensions
cask "discord"                   # Communication platform
cask "zoom"                      # Video conferencing
cask "keycastr"                  # Keystroke visualizer for screencasts
cask "ngrok"                     # Secure tunnels to localhost
cask "termius"                   # SSH client (pairs with Tailscale for mobile access)

# ══════════════════════════════════════════════════════════════════════
# Fonts
# ══════════════════════════════════════════════════════════════════════
cask "font-jetbrains-mono-nerd-font"  # Programming font with icons
cask "font-hack-nerd-font"            # Hack Nerd Font
cask "font-symbols-only-nerd-font"    # Nerd Font symbols only
cask "sf-symbols"                     # Apple SF Symbols (for SketchyBar)

# ══════════════════════════════════════════════════════════════════════
# Node.js Global CLIs (via pnpm)
# ══════════════════════════════════════════════════════════════════════
# These tools are npm packages, not available via Homebrew.
# Install with: pnpm add -g <package>
# pnpm globals persist across fnm/nvm Node version switches.
#
# pnpm add -g vercel          # Vercel deployment CLI
# pnpm add -g convex          # Convex backend CLI
# pnpm add -g trigger.dev     # Trigger.dev background jobs CLI
# pnpm add -g wrangler        # Cloudflare Workers CLI (if needed)
