#!/usr/bin/env bash
# install.sh - Automated dotfiles installation
# Handles Homebrew, dependencies, stow, and first-run setup

set -e  # Exit on error

# ══════════════════════════════════════════════════════════════════════
# Colors for output
# ══════════════════════════════════════════════════════════════════════
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# ══════════════════════════════════════════════════════════════════════
# 1. Check/Install Homebrew
# ══════════════════════════════════════════════════════════════════════
if ! command -v brew &>/dev/null; then
  echo -e "${YELLOW}Homebrew not found. Installing...${NC}"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv)"
else
  echo -e "${GREEN}✓ Homebrew already installed${NC}"
  # Ensure brew is in PATH even if running in non-login shell
  [[ -x /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# ══════════════════════════════════════════════════════════════════════
# 2. Install Dependencies
# ══════════════════════════════════════════════════════════════════════
echo -e "${BLUE}Installing dependencies from Brewfile...${NC}"

# In CI environments, skip GUI packages that won't work headless
if [[ "$CI" == "true" ]]; then
  export HOMEBREW_BUNDLE_CASK_SKIP="wezterm aerospace karabiner-elements"
  export HOMEBREW_BUNDLE_BREW_SKIP="borders sketchybar"
  echo -e "${YELLOW}CI detected: Skipping GUI packages (borders, sketchybar, wezterm, aerospace, karabiner-elements)${NC}"
fi

brew bundle install

# ══════════════════════════════════════════════════════════════════════
# 3. Stow All Packages
# ══════════════════════════════════════════════════════════════════════
echo -e "${BLUE}Stowing dotfiles...${NC}"
packages=(
  aerospace borders dot-gitconfig dot-zprofile dot-zshenv
  gh git karabiner nvim sketchybar ssh starship wezterm zsh
)

for package in "${packages[@]}"; do
  # In CI environments, remove conflicting files before stowing
  if [[ "$CI" == "true" ]]; then
    case "$package" in
      dot-gitconfig)
        rm -f "$HOME/.gitconfig" 2>/dev/null
        ;;
    esac
  fi

  # Capture both stdout and stderr to show useful error messages
  if stow_output=$(stow -R "$package" 2>&1); then
    echo -e "${GREEN}✓ Stowed $package${NC}"
  else
    echo -e "${YELLOW}⚠ Warning: Could not stow $package${NC}"
    # Show the actual error (indented for readability)
    echo "$stow_output" | sed 's/^/   /' | head -5
    echo -e "${YELLOW}   Tip: Check for existing files that conflict with symlinks${NC}"
  fi
done

# ══════════════════════════════════════════════════════════════════════
# 4. Create XDG Directories
# ══════════════════════════════════════════════════════════════════════
echo -e "${BLUE}Creating XDG directories...${NC}"
xdg_dirs=(
  "$HOME/.local/state/zsh"
  "$HOME/.cache/zsh"
  "$HOME/.local/share/zsh"
  "$HOME/.local/share/antidote"
)

for dir in "${xdg_dirs[@]}"; do
  if mkdir -p "$dir" 2>/dev/null; then
    echo -e "${GREEN}✓ Created $dir${NC}"
  else
    echo -e "${YELLOW}⚠ Warning: Could not create $dir${NC}"
  fi
done

# ══════════════════════════════════════════════════════════════════════
# 5. Migrate History
# ══════════════════════════════════════════════════════════════════════
echo -e "${BLUE}Migrating ZSH history...${NC}"
if [[ -f "$HOME/.zsh_history" ]]; then
  mv "$HOME/.zsh_history" "$HOME/.local/state/zsh/history"
  echo -e "${GREEN}✓ Moved ~/.zsh_history to ~/.local/state/zsh/history${NC}"
elif [[ -f "$HOME/.config/zsh/.zsh_history" ]]; then
  mv "$HOME/.config/zsh/.zsh_history" "$HOME/.local/state/zsh/history"
  echo -e "${GREEN}✓ Moved ~/.config/zsh/.zsh_history to ~/.local/state/zsh/history${NC}"
else
  echo -e "${GREEN}✓ No history file to migrate${NC}"
fi

# ══════════════════════════════════════════════════════════════════════
# 6. Backup Old Configs
# ══════════════════════════════════════════════════════════════════════
if [[ -d "$HOME/.oh-my-zsh" ]] || [[ -f "$HOME/.zshrc.backup" ]]; then
  echo -e "${BLUE}Backing up old configs...${NC}"
  mkdir -p "$HOME/dotfiles-backup"
  mv "$HOME/.oh-my-zsh" "$HOME/dotfiles-backup/" 2>/dev/null && echo -e "${GREEN}✓ Backed up .oh-my-zsh${NC}" || true
  mv "$HOME/.zshrc.backup" "$HOME/dotfiles-backup/" 2>/dev/null && echo -e "${GREEN}✓ Backed up .zshrc.backup${NC}" || true
  mv "$HOME/.zshrc.pre-oh-my-zsh" "$HOME/dotfiles-backup/" 2>/dev/null && echo -e "${GREEN}✓ Backed up .zshrc.pre-oh-my-zsh${NC}" || true
  echo -e "${GREEN}Old configs backed up to ~/dotfiles-backup/${NC}"
fi

# ══════════════════════════════════════════════════════════════════════
# 7. Install bat Tokyo Night Theme
# ══════════════════════════════════════════════════════════════════════
if command -v bat &>/dev/null; then
  echo -e "${BLUE}Installing bat Tokyo Night theme...${NC}"
  mkdir -p "$HOME/.config/bat/themes"
  if curl -sL https://raw.githubusercontent.com/folke/tokyonight.nvim/main/extras/sublime/tokyonight_night.tmTheme \
    -o "$HOME/.config/bat/themes/tokyonight_night.tmTheme"; then
    if bat cache --build 2>/dev/null; then
      echo -e "${GREEN}✓ bat Tokyo Night theme installed${NC}"
    else
      echo -e "${YELLOW}⚠ Warning: bat cache rebuild failed${NC}"
    fi
  else
    echo -e "${YELLOW}⚠ Warning: Could not download bat theme${NC}"
  fi
fi

# ══════════════════════════════════════════════════════════════════════
# 8. Success Message
# ══════════════════════════════════════════════════════════════════════
echo ""
echo -e "${GREEN}═══════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}  Dotfiles installed successfully!${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════${NC}"
echo ""
echo "Next steps:"
echo "  1. Restart your terminal or run: exec zsh"
echo "  2. Antidote will auto-install plugins on first shell start"
echo "  3. Test startup time: time zsh -i -c exit"
echo ""
echo "Verify installation:"
echo "  antidote list          # Check plugins"
echo "  eza --version          # Modern ls"
echo "  bat --version          # Syntax cat"
echo "  fzf --version          # Fuzzy finder"
echo ""
