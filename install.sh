#!/usr/bin/env bash
# install.sh - Automated dotfiles installation with robust error handling
# Handles Homebrew, dependencies, stow, and first-run setup

# ══════════════════════════════════════════════════════════════════════
# Strict Error Handling
# ══════════════════════════════════════════════════════════════════════
set -Eeuo pipefail  # Exit on error, undefined vars, pipe failures, inherit ERR trap

# Track installation state for cleanup
INSTALL_STATE=()

# Error handler - shows exactly what failed and where
error_handler() {
  local exit_code=$1
  local line_no=$2
  local bash_command=$3

  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "❌ ERROR: Installation failed at line $line_no"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "Exit code: $exit_code"
  echo "Failed command: $bash_command"
  echo ""
  echo "Installation state when error occurred:"
  if [[ ${#INSTALL_STATE[@]} -eq 0 ]]; then
    echo "  (No steps completed yet)"
  else
    for step in "${INSTALL_STATE[@]}"; do
      echo "  ✓ $step"
    done
  fi
  echo ""
  echo "To get help:"
  echo "  - Check the error message above"
  echo "  - Review the Brewfile for package issues"
  echo "  - Ensure you have write permissions to HOME directory"
  echo "  - Check existing files that might conflict with symlinks"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
}

# Set up error trap
trap 'error_handler $? $LINENO "$BASH_COMMAND"' ERR

# ══════════════════════════════════════════════════════════════════════
# Helper Functions
# ══════════════════════════════════════════════════════════════════════

# Fatal error - exit immediately
fatal() {
  local message=$1
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "❌ FATAL ERROR: $message"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  exit 1
}

# Warning - non-critical issue
warn() {
  local message=$1
  echo "⚠️  WARNING: $message"
}

# Check if command exists
check_command() {
  local cmd=$1
  local pkg_name=${2:-$cmd}

  if ! command -v "$cmd" &>/dev/null; then
    fatal "$pkg_name not found. Expected it to be installed by brew bundle."
  fi
}

# Backup file with verification
backup_file() {
  local file=$1
  local backup_dir="$HOME/dotfiles-backup/$(date +%Y%m%d_%H%M%S)"

  # Nothing to backup if file doesn't exist
  [[ ! -e "$file" ]] && return 0

  # Create backup directory
  if ! mkdir -p "$backup_dir"; then
    fatal "Cannot create backup directory: $backup_dir"
  fi

  # Perform backup
  if ! cp -R "$file" "$backup_dir/"; then
    fatal "Backup failed for: $file"
  fi

  echo "  ✓ Backed up: $(basename "$file") → $backup_dir/"
  return 0
}

# Colors for output
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# ══════════════════════════════════════════════════════════════════════
# 1. Detect and Setup Homebrew (Cross-Platform)
# ══════════════════════════════════════════════════════════════════════
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}  Step 1: Homebrew Setup${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

detect_and_setup_brew() {
  # Check if brew is already in PATH
  if command -v brew &>/dev/null; then
    echo -e "${GREEN}✓ Homebrew already installed and in PATH${NC}"
    return 0
  fi

  # Try to find brew in common locations (cross-platform)
  local brew_paths=(
    "/opt/homebrew/bin/brew"          # Apple Silicon Mac
    "/usr/local/bin/brew"              # Intel Mac
    "/home/linuxbrew/.linuxbrew/bin/brew"  # Linux
  )

  for brew_path in "${brew_paths[@]}"; do
    if [[ -x "$brew_path" ]]; then
      echo -e "${GREEN}✓ Found Homebrew at $brew_path${NC}"
      eval "$("$brew_path" shellenv)"
      return 0
    fi
  done

  # Homebrew not found - install it
  echo -e "${YELLOW}Homebrew not found. Installing...${NC}"
  if ! /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; then
    fatal "Homebrew installation failed"
  fi

  # Try to set up shell environment after installation
  for brew_path in "${brew_paths[@]}"; do
    if [[ -x "$brew_path" ]]; then
      eval "$("$brew_path" shellenv)"
      echo -e "${GREEN}✓ Homebrew installed successfully${NC}"
      return 0
    fi
  done

  fatal "Homebrew installation succeeded but cannot find brew command"
}

detect_and_setup_brew
INSTALL_STATE+=("Homebrew setup")

# Show brew info
echo "  Homebrew prefix: $(brew --prefix)"
echo "  Architecture: $(uname -m)"

# ══════════════════════════════════════════════════════════════════════
# 2. Install Dependencies via Homebrew
# ══════════════════════════════════════════════════════════════════════
echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}  Step 2: Installing Dependencies${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# In CI environments, skip GUI packages that won't work headless
if [[ "${CI:-false}" == "true" ]]; then
  export HOMEBREW_BUNDLE_CASK_SKIP="wezterm aerospace karabiner-elements"
  export HOMEBREW_BUNDLE_BREW_SKIP="borders sketchybar"
  echo -e "${YELLOW}CI detected: Skipping GUI packages${NC}"
fi

# Run brew bundle - CRITICAL: must succeed
echo "Installing packages from Brewfile..."
if ! brew bundle install; then
  fatal "Brew bundle installation failed. Check Brewfile for issues."
fi
echo -e "${GREEN}✓ All Homebrew packages installed${NC}"
INSTALL_STATE+=("Homebrew packages installed")

# Verify critical packages are actually installed
echo "Verifying critical packages..."
check_command stow "GNU Stow"
check_command zsh "ZSH shell"
check_command git "Git"
echo -e "${GREEN}✓ Critical packages verified${NC}"

# ══════════════════════════════════════════════════════════════════════
# 3. Create XDG Base Directories (CRITICAL)
# ══════════════════════════════════════════════════════════════════════
echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}  Step 3: Creating XDG Directories${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

# Critical directories that MUST be writable
critical_dirs=(
  "$HOME/.config"
  "$HOME/.local/share"
  "$HOME/.cache"
  "$HOME/.local/state"
)

# ZSH-specific directories
# NOTE: antidote directory is NOT created here - it's created by 06-plugins.zsh during first ZSH startup
zsh_dirs=(
  "$HOME/.local/state/zsh"
  "$HOME/.cache/zsh"
  "$HOME/.local/share/zsh"
)

all_dirs=("${critical_dirs[@]}" "${zsh_dirs[@]}")

for dir in "${all_dirs[@]}"; do
  # Try to create directory
  if ! mkdir -p "$dir" 2>&1; then
    fatal "Cannot create required directory: $dir"
  fi

  # Verify directory is writable
  if ! touch "$dir/.write-test" 2>/dev/null; then
    fatal "Directory $dir is not writable. Check permissions."
  fi
  rm "$dir/.write-test"

  echo "  ✓ $dir"
done

echo -e "${GREEN}✓ All XDG directories created and verified${NC}"
INSTALL_STATE+=("XDG directories created")

# ══════════════════════════════════════════════════════════════════════
# 4. Backup Existing Configs
# ══════════════════════════════════════════════════════════════════════
echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}  Step 4: Backing Up Old Configs${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

old_configs=(
  "$HOME/.oh-my-zsh"
  "$HOME/.zshrc.backup"
  "$HOME/.zshrc.pre-oh-my-zsh"
)

backup_needed=false
for config in "${old_configs[@]}"; do
  if [[ -e "$config" ]]; then
    backup_needed=true
    break
  fi
done

if $backup_needed; then
  for config in "${old_configs[@]}"; do
    backup_file "$config"
  done
  echo -e "${GREEN}✓ Old configs backed up to ~/dotfiles-backup/${NC}"
  INSTALL_STATE+=("Old configs backed up")
else
  echo "  No old configs found to backup"
fi

# ══════════════════════════════════════════════════════════════════════
# 5. Stow Dotfiles with Conflict Detection
# ══════════════════════════════════════════════════════════════════════
echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}  Step 5: Stowing Dotfiles${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

packages=(
  aerospace borders claude claude-hooks dot-gitconfig dot-zprofile dot-zshenv
  gh git karabiner nvim scripts sketchybar ssh starship tmux wezterm zsh
)

stow_package() {
  local package=$1

  # In CI, remove known conflicting files
  if [[ "${CI:-false}" == "true" ]]; then
    case "$package" in
      dot-gitconfig)
        rm -f "$HOME/.gitconfig" 2>/dev/null || true
        ;;
    esac
  fi

  # First, simulate to detect conflicts
  if stow --simulate -R "$package" &>/dev/null; then
    # No conflicts - proceed with actual stow
    if stow -R "$package" 2>&1; then
      echo "  ✓ $package"
      return 0
    else
      fatal "Stow failed for $package (unexpected error after successful simulation)"
    fi
  else
    # Conflicts detected - show them
    echo ""
    echo -e "${RED}❌ CONFLICT detected in package: $package${NC}"
    echo ""
    echo "Conflicting files:"
    stow --simulate -R "$package" 2>&1 | grep -i "existing\|conflict" | head -5 || true
    echo ""
    fatal "Cannot stow $package due to conflicts. Backup/remove conflicting files and re-run."
  fi
}

for package in "${packages[@]}"; do
  stow_package "$package"
done

echo -e "${GREEN}✓ All packages stowed successfully${NC}"
INSTALL_STATE+=("Dotfiles stowed")

# ══════════════════════════════════════════════════════════════════════
# 6. Migrate ZSH History
# ══════════════════════════════════════════════════════════════════════
echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}  Step 6: Migrating ZSH History${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

migrate_history() {
  local source_files=("$HOME/.zsh_history" "$HOME/.config/zsh/.zsh_history")
  local target="$HOME/.local/state/zsh/history"
  local migrated=false

  # If target already exists, don't migrate
  if [[ -f "$target" ]]; then
    echo "  History already exists at $target"
    return 0
  fi

  for source in "${source_files[@]}"; do
    if [[ -f "$source" ]]; then
      echo "  Found history at: $source"

      # Backup original first
      if ! cp "$source" "${source}.backup"; then
        fatal "Cannot backup history file: $source"
      fi

      # Verify target directory exists (should from step 3)
      if [[ ! -d "$(dirname "$target")" ]]; then
        fatal "Target directory doesn't exist: $(dirname "$target")"
      fi

      # Move with verification
      if mv "$source" "$target"; then
        echo "  ✓ Migrated: $source → $target"
        # Remove backup on success
        rm "${source}.backup"
        migrated=true
        break  # Only migrate the first one found
      else
        # Restore from backup on failure
        mv "${source}.backup" "$source"
        fatal "History migration failed, restored original from ${source}.backup"
      fi
    fi
  done

  if ! $migrated; then
    echo "  No history file found to migrate"
  fi
}

migrate_history
INSTALL_STATE+=("History migrated")

# ══════════════════════════════════════════════════════════════════════
# 7. Setup brew-autoupdate for Automated Maintenance
# ══════════════════════════════════════════════════════════════════════
echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}  Step 7: Setting Up Automated Homebrew Updates${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

if brew tap | grep -q "domt4/autoupdate"; then
  echo -e "${GREEN}✓ brew-autoupdate already tapped${NC}"
else
  echo "Tapping DomT4/homebrew-autoupdate..."
  if brew tap DomT4/homebrew-autoupdate 2>&1; then
    echo -e "${GREEN}✓ brew-autoupdate tapped${NC}"
  else
    warn "Could not tap brew-autoupdate (non-critical)"
  fi
fi

# Check if autoupdate is already running
if brew autoupdate status 2>&1 | grep -q "running"; then
  echo -e "${GREEN}✓ brew-autoupdate already configured${NC}"
else
  echo "Configuring brew-autoupdate (daily updates + cleanup)..."
  if brew autoupdate start --upgrade --cleanup 2>&1; then
    echo -e "${GREEN}✓ brew-autoupdate configured${NC}"
    echo "  Homebrew will auto-update daily via macOS launchd"
  else
    warn "Could not configure brew-autoupdate (non-critical, you can do it manually)"
  fi
fi

INSTALL_STATE+=("brew-autoupdate configured")

# ══════════════════════════════════════════════════════════════════════
# 8. Install bat Tokyo Night Theme (Optional)
# ══════════════════════════════════════════════════════════════════════
echo ""
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${CYAN}  Step 8: Installing bat Tokyo Night Theme (Optional)${NC}"
echo -e "${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

if command -v bat &>/dev/null; then
  # Create themes directory
  if mkdir -p "$HOME/.config/bat/themes" 2>/dev/null; then
    # Download with proper curl flags: fail on error, follow redirects, show errors, retry
    if curl -fsSL --retry 3 --max-time 30 \
      "https://raw.githubusercontent.com/folke/tokyonight.nvim/main/extras/sublime/tokyonight_night.tmTheme" \
      -o "$HOME/.config/bat/themes/tokyonight_night.tmTheme" 2>&1; then

      # Rebuild cache
      if bat cache --build &>/dev/null; then
        echo -e "${GREEN}✓ bat Tokyo Night theme installed${NC}"
      else
        warn "bat cache rebuild failed (theme may not activate)"
      fi
    else
      warn "Could not download bat theme (network issue?)"
    fi
  else
    warn "Cannot create bat themes directory"
  fi
else
  echo "  bat not installed, skipping theme setup"
fi

# ══════════════════════════════════════════════════════════════════════
# 9. Success Message
# ══════════════════════════════════════════════════════════════════════
echo ""
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${GREEN}  ✓ Dotfiles Installed Successfully!${NC}"
echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "Installation completed the following steps:"
for step in "${INSTALL_STATE[@]}"; do
  echo "  ✓ $step"
done
echo ""
echo -e "${CYAN}Next Steps:${NC}"
echo "  1. Restart your terminal or run: ${YELLOW}exec zsh${NC}"
echo "  2. Antidote will auto-install plugins on first shell start"
echo "  3. Test startup time: ${YELLOW}time zsh -i -c exit${NC}"
echo ""
echo -e "${CYAN}Automated Maintenance (brew-autoupdate):${NC}"
echo "  ${YELLOW}brew autoupdate status${NC}     # Check autoupdate status"
echo "  Homebrew auto-updates daily at $(date +%H:%M) via macOS launchd"
echo "  Packages in Brewfile are kept up-to-date automatically"
echo ""
echo -e "${CYAN}Verify Installation:${NC}"
echo "  ${YELLOW}antidote list${NC}          # Check plugins"
echo "  ${YELLOW}eza --version${NC}          # Modern ls"
echo "  ${YELLOW}bat --version${NC}          # Syntax cat"
echo "  ${YELLOW}fzf --version${NC}          # Fuzzy finder"
echo ""
echo -e "${CYAN}Brewfile-First Workflow:${NC}"
echo "  Always add packages to Brewfile first, then: ${YELLOW}brew bundle install${NC}"
echo "  Monthly cleanup: ${YELLOW}brew bundle cleanup --force${NC}"
echo "  See ${YELLOW}docs/GUIDE.md${NC} for detailed workflow documentation"
echo ""
