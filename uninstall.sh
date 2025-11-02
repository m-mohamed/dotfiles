#!/usr/bin/env bash
# uninstall.sh - Uninstall dotfiles and restore system to clean state

set -e

RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${YELLOW}═══════════════════════════════════════════════════════${NC}"
echo -e "${YELLOW}  Dotfiles Uninstaller${NC}"
echo -e "${YELLOW}═══════════════════════════════════════════════════════${NC}"
echo ""
echo "This will:"
echo "  1. Remove all stowed symlinks"
echo "  2. Restore backed up configs (if any)"
echo "  3. Clean up generated files"
echo ""
echo -e "${RED}WARNING: This does NOT uninstall Homebrew or packages${NC}"
echo -e "${RED}WARNING: This will remove all ZSH configuration symlinks${NC}"
echo ""
read -p "Continue? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
  echo "Aborted."
  exit 0
fi

echo ""
echo -e "${BLUE}1. Unstowing all packages...${NC}"
packages=(
  aerospace borders dot-gitconfig dot-zprofile dot-zshenv
  gh git karabiner nvim sketchybar ssh starship wezterm zsh
)

for package in "${packages[@]}"; do
  if stow -D "$package" 2>/dev/null; then
    echo -e "${GREEN}✓ Unstowed $package${NC}"
  else
    echo -e "${YELLOW}⚠ $package not stowed or already removed${NC}"
  fi
done

echo ""
echo -e "${BLUE}2. Restoring backed up configs...${NC}"
if [[ -d "$HOME/dotfiles-backup" ]]; then
  count=0
  for backup in "$HOME/dotfiles-backup"/*; do
    if [[ -e "$backup" ]]; then
      filename=$(basename "$backup")
      target="$HOME/$filename"
      if [[ ! -e "$target" ]]; then
        mv "$backup" "$target"
        echo -e "${GREEN}✓ Restored $filename${NC}"
        ((count++))
      else
        echo -e "${YELLOW}⚠ $filename already exists, keeping backup${NC}"
      fi
    fi
  done

  if [[ $count -gt 0 ]]; then
    rmdir "$HOME/dotfiles-backup" 2>/dev/null && echo -e "${GREEN}✓ Removed empty backup directory${NC}" || true
  fi
else
  echo -e "${GREEN}✓ No backups to restore${NC}"
fi

echo ""
echo -e "${BLUE}3. Cleaning generated files...${NC}"

# Clean completion dumps
if rm -f "$HOME/.cache/zsh/.zcompdump"* 2>/dev/null; then
  echo -e "${GREEN}✓ Removed completion cache${NC}"
else
  echo -e "${YELLOW}⚠ No completion cache found${NC}"
fi

# Clean generated plugin file
if rm -f "$HOME/.config/zsh/.zsh_plugins.zsh" 2>/dev/null; then
  echo -e "${GREEN}✓ Removed generated plugins${NC}"
else
  echo -e "${YELLOW}⚠ No generated plugin file found${NC}"
fi

# Don't delete history (user might want to keep it)
if [[ -f "$HOME/.local/state/zsh/history" ]]; then
  echo -e "${YELLOW}ℹ Keeping ZSH history: ~/.local/state/zsh/history${NC}"
  echo -e "${YELLOW}  Delete manually if desired: rm ~/.local/state/zsh/history${NC}"
fi

echo ""
echo -e "${GREEN}═══════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}  Dotfiles uninstalled successfully!${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════${NC}"
echo ""
echo "Next steps:"
echo "  1. Restart your terminal or run: exec zsh"
echo "  2. Remove ~/dotfiles directory if desired:"
echo "     ${BLUE}rm -rf ~/dotfiles${NC}"
echo ""
echo "  3. To uninstall Homebrew packages (OPTIONAL):"
echo "     ${BLUE}cd ~/dotfiles${NC}"
echo "     ${BLUE}brew bundle cleanup --force${NC}"
echo "     This will remove packages in Brewfile not installed by other means"
echo ""
echo "  4. To completely remove Homebrew (EXTREME):"
echo "     ${RED}Only do this if you're sure!${NC}"
echo "     Visit: https://github.com/homebrew/install#uninstall-homebrew"
echo ""
