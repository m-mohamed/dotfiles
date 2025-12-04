# Nix + Home Manager Migration Plan

**Status:** Research & Planning Phase
**Goal:** Perfect cross-platform reproducibility (M1 Mac + Raspberry Pi 5)
**Current:** Homebrew + GNU Stow
**Target:** Nix + Home Manager

---

## Executive Summary

This document outlines the complete migration from Homebrew + GNU Stow to Nix + Home Manager based on comprehensive research of best practices, real-world examples, and solutions to common pitfalls discovered in 2024-2025.

### Key Decision: Full Migration is Viable

After reviewing the concerns from developers who left Nix (notably the video about returning to Stow), we discovered **`mkOutOfStoreSymlink`** - a built-in Home Manager function that solves all the major issues:

- ✅ LazyVim lock file updates work (no rebuild needed)
- ✅ Instant config changes for frequently-edited files
- ✅ No file ownership problems
- ✅ Still get cross-platform package reproducibility
- ✅ **Mason works perfectly** - manages ALL LSPs without interference from Nix

**Critical Tools Discovered:**
- **nix-homebrew** - Seamless Homebrew migration with automatic detection and version pinning
- **raspberry-pi-nix** - Community module with pre-built kernels for Pi 5 (no Mac compilation needed!)
- **cachix** - Binary cache to avoid building packages locally

### Why This Works for Our Use Case

**Different from the video creator:**
- We have **2 machines** (M1 Mac + Raspberry Pi 5) → Nix's cross-platform is essential
- They had **1 machine** (macOS only) → Stow was sufficient
- We need **identical tool versions** across platforms → Nix's flake.lock crucial
- They didn't need cross-platform → No benefit from Nix's reproducibility

**LazyVim "No Sacrifices" Approach:**
- Nix manages ONLY the Neovim binary (same version Mac/Pi)
- Mason manages ALL LSPs, formatters, linters (works exactly as designed)
- Config is mutable via mkOutOfStoreSymlink (instant edits, no rebuild)
- `:Lazy update` and `:Mason install` work perfectly

---

## Research Findings

### 0. Critical Tools & Integrations (Must-Have!)

#### nix-homebrew - Seamless Homebrew Migration

**What:** Homebrew installation manager for nix-darwin
**Why:** Makes Homebrew migration painless with automatic detection and version pinning

**Key Features:**
- `autoMigrate` option automatically detects and migrates existing Homebrew installations
- Pins Homebrew version itself (not just packages)
- Declarative tap management
- Works in tandem with nix-darwin's `homebrew.*` options

**GitHub:** https://github.com/zhaofengli/nix-homebrew

**How to Use:**
```nix
# Add to flake.nix inputs
nix-homebrew = {
  url = "github:zhaofengli/nix-homebrew";
  inputs.nixpkgs.follows = "nixpkgs";
};

# In hosts/macbook/homebrew.nix
nix-homebrew = {
  enable = true;
  enableRosetta = true;  # For x86 packages on Apple Silicon
  user = "mohamedmohamed";
  autoMigrate = true;  # Automatically migrate existing Homebrew!
};
```

#### raspberry-pi-nix - Official Raspberry Pi Support

**What:** NixOS modules for Raspberry Pi with pre-built kernels
**Why:** Avoid compiling Linux kernel on your Mac - use pre-built binaries!

**Key Features:**
- Pre-configured kernel, device tree, and bootloader for Pi hardware
- Pre-built kernels pushed to cachix (download instead of compile!)
- SD card image builder included
- Full support for Pi 5 (`bcm2712` architecture)

**GitHub:** https://github.com/nix-community/raspberry-pi-nix
**Cachix:** https://nix-community.cachix.org

**How to Use:**
```nix
# Add to flake.nix inputs
raspberry-pi-nix = {
  url = "github:nix-community/raspberry-pi-nix";
  inputs.nixpkgs.follows = "nixpkgs";
};

# In hosts/raspberry-pi/default.nix
imports = [ raspberry-pi-nix.nixosModules.raspberry-pi ];
raspberry-pi-nix.board = "bcm2712";  # Pi 5

# Add binary cache
nix.settings = {
  substituters = [ "https://nix-community.cachix.org" ];
  trusted-public-keys = [
    "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
  ];
};
```

#### Binary Caches - Speed Up Everything

**What:** Pre-built package servers (avoid local compilation)
**Why:** Most packages download instantly instead of building for hours

**Official Cache:** https://cache.nixos.org (enabled by default)
**Community Cache:** https://nix-community.cachix.org (for raspberry-pi-nix, etc.)

**Note:** With these caches, you'll rarely compile anything yourself!

---

### 1. Real-World Examples (Similar Stacks)

#### Top Reference Repositories

**[WTanardi/nix-config](https://github.com/WTanardi/nix-config)**
- Stack: ZSH + Neovim + Starship
- Perfect match for our use case
- Clean modular structure

**[breuerfelix/dotfiles](https://github.com/breuerfelix/dotfiles)**
- Stack: macOS + nix-darwin + home-manager + zsh + neovim
- Excellent darwin/ and home-manager/ separation
- Great reference for macOS-specific patterns

**[appaquet/dotfiles](https://github.com/appaquet/dotfiles)**
- Stack: NixOS + nix-darwin + home-manager
- Cross-platform setup (exactly like ours!)
- Good example of shared modules

**[gesi/dotfiles](https://github.com/gesi/dotfiles)**
- Stack: macOS + nix + nix-darwin + home-manager + homebrew
- Shows hybrid approach (Nix + Homebrew coexisting)

### 2. Best Practices for `mkOutOfStoreSymlink`

**Source:** [Jean-Charles Quillet - The home-manager function that changes everything](https://jeancharles.quillet.org/posts/2023-02-07-The-home-manager-function-that-changes-everything.html)

**Core Pattern:**
```nix
# Define path to your mutable dotfiles
nvimPath = "${config.home.homeDirectory}/dotfiles/nvim/.config/nvim";

# Symlink outside Nix store (mutable!)
xdg.configFile."nvim".source = config.lib.file.mkOutOfStoreSymlink nvimPath;
```

**When to Use:**
- ✅ Configs that change frequently (nvim, zsh)
- ✅ Configs that need to be mutable (LazyVim lock files)
- ✅ When you want instant changes without rebuild

**When NOT to Use:**
- ❌ Configs that rarely change (prefer declarative)
- ❌ When you want pure reproducibility
- ❌ System-critical configs (use Nix store for safety)

**Important Caveat:**
- Not compatible with `nixpkgs#nixVersions.unstable` (Nix 2.19.2)
- Works with stable Nix versions

### 3. Flake Structure Best Practices

**Source:** [NixOS & Flakes Book - Modularize Configuration](https://nixos-and-flakes.thiscute.world/nixos-with-flakes/modularize-the-configuration)

**Recommended Structure:**
```
nix-config/
├── flake.nix           # Entry point
├── flake.lock          # Version pins (auto-generated)
├── hosts/              # Machine-specific system configs
│   ├── macbook/
│   │   ├── default.nix
│   │   ├── homebrew.nix
│   │   └── hardware.nix
│   └── raspberry-pi/
│       ├── default.nix
│       └── hardware-configuration.nix
├── home/               # User environment (cross-platform)
│   ├── common.nix      # Shared configs
│   ├── darwin.nix      # macOS-specific
│   ├── linux.nix       # Linux-specific
│   └── programs/       # Per-program modules
│       ├── zsh.nix
│       ├── git.nix
│       ├── neovim.nix
│       └── starship.nix
└── secrets/
    ├── secrets.yaml    # Encrypted (sops-nix)
    └── .sops.yaml
```

**Key Principles:**
1. **Separation of Concerns:** System (hosts/) vs User (home/)
2. **Platform Isolation:** Common vs Darwin vs Linux
3. **Modularity:** One file per program
4. **Conditional Imports:** Use `lib.optionals` for platform-specific modules

### 4. Cross-Platform Strategy

**Source:** [Managing dotfiles on macOS with Nix](https://davi.sh/blog/2024/02/nix-home-manager/)

**Best Practice:** Default to home-manager for anything not macOS-specific.

**Rationale:**
- home-manager works on NixOS, macOS, and any Linux
- All home-manager config continues to work if you move to NixOS
- nix-darwin is ONLY for macOS system settings

**Our Approach:**
```nix
# home/common.nix - Works EVERYWHERE
programs.zsh = { enable = true; ... };
programs.git = { enable = true; ... };
programs.neovim = { enable = true; ... };

# home/darwin.nix - macOS-only
xdg.configFile."karabiner" = ...;
xdg.configFile."aerospace" = ...;

# hosts/macbook/default.nix - System-level macOS
system.defaults.dock = { ... };
security.pam.enableSudoTouchIdAuth = true;
```

### 5. LazyVim Integration Best Practices

**Source:** [LazyVim Discussion #1972](https://github.com/LazyVim/LazyVim/discussions/1972)

**Consensus:** LazyVim works perfectly with `mkOutOfStoreSymlink` - **zero sacrifices required!**

**The "No Sacrifices" Approach (RECOMMENDED):**
```nix
# home/programs/neovim.nix
{ pkgs, config, ... }: {
  # Nix ONLY manages the Neovim binary
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    # Only install utilities that Neovim uses (NOT LSPs!)
    extraPackages = with pkgs; [
      ripgrep  # Telescope search
      fd       # Telescope file picker
      gcc      # Treesitter compilation
    ];
  };

  # LazyVim config is mutable (mkOutOfStoreSymlink)
  # Mason manages ALL LSPs/formatters/linters
  xdg.configFile."nvim".source = config.lib.file.mkOutOfStoreSymlink
    "${config.home.homeDirectory}/dotfiles/nvim/.config/nvim";
}
```

**Result - LazyVim Works Exactly As Designed:**
- ✅ Same Neovim binary version across Mac/Pi (Nix-managed)
- ✅ Same utilities (ripgrep, fd) across platforms (Nix-managed)
- ✅ Mason manages ALL LSPs, formatters, linters (zero interference!)
- ✅ `:Mason install lua-language-server` works perfectly
- ✅ `:Lazy update` works perfectly
- ✅ `lazy-lock.json` updates freely
- ✅ Edit config → instant changes (no rebuild)
- ✅ Zero sacrifices to LazyVim workflow!

**Why This Works:**
- LazyVim config lives in `~/dotfiles/nvim/.config/nvim` (mutable!)
- Mason installs to `~/.local/share/nvim/mason` (outside Nix store!)
- Everything LazyVim expects to manage, it manages
- Nix only ensures you have the same Neovim version everywhere

**Alternative: "Hybrid" Approach (Not Recommended Unless You Have Specific Needs)**

If you want some LSPs managed by Nix (for specific reasons), you can:
```nix
extraPackages = with pkgs; [
  ripgrep
  fd
  gcc
  # Optional: Install some LSPs via Nix if you want
  lua-language-server  # Example: Nix-managed Lua LSP
  nil                  # Example: Nix-managed Nix LSP
];
```

**Trade-offs:**
- ✅ LSPs reproducible across machines
- ❌ Can't use Mason to manage these LSPs
- ❌ More complex to update (need to rebuild Nix config)

**Our Recommendation:** Stick with the "No Sacrifices" approach - let Mason handle everything!

### 6. Raspberry Pi NixOS Setup

**Source:** [NixOS on ARM/Raspberry Pi 4](https://nixos.wiki/wiki/NixOS_on_ARM/Raspberry_Pi_4)

**Key Findings:**

**Cross-Compilation:**
- Build Pi config from Mac using QEMU: `boot.binfmt.emulatedSystems = [ "aarch64-linux" ];`
- Or build directly on Pi (slower but simpler)

**Remote Deployment:**
```bash
nixos-rebuild switch --flake .#raspberry-pi \
  --target-host mohamed@pi-ip \
  --use-remote-sudo
```

**Home Manager Integration:**
```nix
nixosConfigurations."raspberry-pi" = nixpkgs.lib.nixosSystem {
  modules = [
    home-manager.nixosModules.home-manager
    {
      home-manager.users.mohamed = import ./home/common.nix;
    }
  ];
};
```

### 7. Secrets Management

**Source:** [sops-nix](https://github.com/Mic92/sops-nix)

**Best Practice:** Use sops-nix for encrypted secrets.

**Setup:**
```bash
# Generate age key
age-keygen -o ~/.config/sops/age/keys.txt

# Configure sops
# secrets/.sops.yaml
keys:
  - &me age1xxxxxxxxx
creation_rules:
  - path_regex: secrets/secrets\.yaml$
    key_groups:
      - age: [*me]

# Encrypt secrets
sops -e secrets.yaml
```

**Integration:**
```nix
sops.secrets.openai_api_key = {
  path = "${config.home.homeDirectory}/.secrets/openai";
};
```

**CRITICAL:** Verify secrets NOT in /nix/store:
```bash
nix-store --query --references /run/current-system | grep -i secret
# Should return nothing!
```

---

## Migration Strategy

### Phase 1: Foundation (No Breaking Changes)

**Goal:** Install Nix alongside Homebrew, create basic flake

**Actions:**
1. Install Nix (Determinate Systems installer)
2. Create `~/nix-config/` repo (separate from `~/dotfiles`)
3. Create minimal `flake.nix` with nix-darwin + home-manager
4. First successful build
5. **Keep Homebrew completely untouched**

**Safety:** Both systems coexist peacefully.

### Phase 2: Package Migration

**Goal:** Replace Homebrew CLI tools with Nix equivalents

**Actions:**
1. Add packages to `home.packages`
2. Verify Nix packages work (shadow Homebrew in PATH)
3. Test extensively
4. **Still don't uninstall Homebrew** (parallel safety)

**Result:** Same package versions on Mac and Pi (via flake.lock)

### Phase 3: Config Migration (mkOutOfStoreSymlink)

**Goal:** Point Home Manager to existing dotfiles

**Actions:**
1. Use `mkOutOfStoreSymlink` for nvim, zsh, karabiner, etc.
2. Configs stay in `~/dotfiles` (just like Stow!)
3. LazyVim works freely
4. Instant config changes (no rebuild)

**Result:** Best of both worlds - Nix manages packages, configs are mutable

### Phase 4: Declarative Configs

**Goal:** Move stable configs to Nix declarations

**Actions:**
1. Migrate git config to `programs.git`
2. Migrate starship to `programs.starship`
3. Migrate shell tools to `programs.*`
4. **Only if they rarely change**

**Result:** Some configs declarative (git, starship), some mutable (nvim, zsh)

### Phase 5: macOS System Settings

**Goal:** Declarative system configuration

**Actions:**
1. Configure `system.defaults` (dock, finder, keyboard)
2. Enable TouchID for sudo
3. Manage Homebrew via nix-darwin (declarative casks/brews)

**Result:** Fresh Mac can be configured with one command

### Phase 6: Raspberry Pi

**Goal:** Deploy identical environment to Pi

**Actions:**
1. Install NixOS on Pi
2. Create `hosts/raspberry-pi/` config
3. Deploy remotely from Mac
4. Verify tool versions match Mac

**Result:** Perfect cross-platform reproducibility achieved

### Phase 7: Cleanup (Only After Stable)

**Goal:** Remove old Stow setup

**Actions:**
1. Test for 2+ weeks
2. Unstow all packages
3. Uninstall Homebrew CLI tools (keep GUI apps)
4. Archive `~/dotfiles` → `~/dotfiles-archive`

**Safety:** Keep archive for 6+ months as emergency rollback

---

## Complete Implementation Plan

### Repository: `~/nix-config`

**New repo following community conventions.**

**Keep `~/dotfiles`** as your mutable config source (mkOutOfStoreSymlink references it).

### Step 1: Install Nix

```bash
# Determinate Systems installer (best for macOS)
curl --proto '=https' --tlsv1.2 -sSf -L \
  https://install.determinate.systems/nix | sh -s -- install

# Restart terminal
exec zsh

# Verify
nix --version
nix flake --help
```

### Step 2: Create Repository

```bash
mkdir ~/nix-config
cd ~/nix-config
git init

# Create structure
mkdir -p hosts/macbook home/programs secrets

# .gitignore
cat > .gitignore << 'EOF'
result
result-*
.DS_Store
EOF

git add .
git commit -m "chore: initial nix-config structure"
```

### Step 3: Create flake.nix

**File: `~/nix-config/flake.nix`**

```nix
{
  description = "Mohamed's cross-platform Nix configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Seamless Homebrew migration
    nix-homebrew = {
      url = "github:zhaofengli/nix-homebrew";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Raspberry Pi 5 support with pre-built kernels
    raspberry-pi-nix = {
      url = "github:nix-community/raspberry-pi-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nix-darwin, home-manager, nix-homebrew, raspberry-pi-nix, sops-nix }: {
    # macOS configuration
    darwinConfigurations."macbook" = nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      modules = [
        ./hosts/macbook
        home-manager.darwinModules.home-manager
        nix-homebrew.darwinModules.nix-homebrew
        sops-nix.darwinModules.sops
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.mohamedmohamed = import ./home/darwin.nix;
          };
        }
      ];
    };

    # Raspberry Pi 5 configuration
    nixosConfigurations."raspberry-pi" = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      modules = [
        ./hosts/raspberry-pi
        raspberry-pi-nix.nixosModules.raspberry-pi
        home-manager.nixosModules.home-manager
        sops-nix.nixosModules.sops
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.mohamed = import ./home/linux.nix;
          };
        }
      ];
    };
  };
}
```

### Step 4: macOS System Config

**File: `~/nix-config/hosts/macbook/default.nix`**

```nix
{ config, pkgs, ... }: {
  imports = [ ./homebrew.nix ];

  # Enable nix-daemon
  services.nix-daemon.enable = true;

  # Allow unfree packages (fonts, etc.)
  nixpkgs.config.allowUnfree = true;

  # Nix settings
  nix = {
    settings = {
      experimental-features = "nix-command flakes";
      auto-optimise-store = true;
      trusted-users = [ "@admin" ];
    };

    # Automatic garbage collection
    gc = {
      automatic = true;
      interval = { Weekday = 0; Hour = 2; Minute = 0; };  # Sunday 2 AM
      options = "--delete-older-than 30d";
    };
  };

  # macOS system settings
  system = {
    stateVersion = 5;

    defaults = {
      dock = {
        autohide = true;
        show-recents = false;
        tilesize = 48;
        mru-spaces = false;
      };

      finder = {
        AppleShowAllExtensions = true;
        FXEnableExtensionChangeWarning = false;
        ShowPathbar = true;
        ShowStatusBar = true;
      };

      NSGlobalDomain = {
        AppleKeyboardUIMode = 3;
        ApplePressAndHoldEnabled = false;
        InitialKeyRepeat = 15;
        KeyRepeat = 2;
        NSAutomaticCapitalizationEnabled = false;
        NSAutomaticDashSubstitutionEnabled = false;
        NSAutomaticPeriodSubstitutionEnabled = false;
        NSAutomaticQuoteSubstitutionEnabled = false;
        NSAutomaticSpellingCorrectionEnabled = false;
      };
    };

    # Note: Caps Lock remapping handled by Karabiner-Elements
    # (nix-darwin's system.keyboard.remapCapsLockToEscape has a known bug
    # where it gets erased on restart as of March 2024)
  };

  # Security
  security.pam.enableSudoTouchIdAuth = true;

  # Minimal system packages
  environment.systemPackages = with pkgs; [
    vim
    git
  ];
}
```

**File: `~/nix-config/hosts/macbook/homebrew.nix`**

```nix
{ config, pkgs, ... }: {
  # nix-homebrew: Manages Homebrew installation itself
  nix-homebrew = {
    enable = true;
    enableRosetta = true;  # For x86 packages on Apple Silicon
    user = "mohamedmohamed";
    autoMigrate = true;  # Automatically migrate existing Homebrew installation
  };

  # Declarative Homebrew package management
  homebrew = {
    enable = true;

    onActivation = {
      autoUpdate = false;
      cleanup = "zap";  # Uninstall packages not in Brewfile
      upgrade = false;
    };

    taps = [
      "FelixKratz/formulae"
      "nikitabobko/tap"
    ];

    brews = [
      "borders"
      "sketchybar"
    ];

    casks = [
      "aerospace"
      "karabiner-elements"  # Handles Caps Lock → Escape remapping
      "wezterm"
      "font-jetbrains-mono-nerd-font"
      "font-symbols-only-nerd-font"
      "sf-symbols"
    ];
  };
}
```

### Step 5: Home Manager Common Config

**File: `~/nix-config/home/common.nix`**

```nix
{ config, pkgs, lib, ... }: {
  imports = [
    ./programs/zsh.nix
    ./programs/git.nix
    ./programs/neovim.nix
    ./programs/starship.nix
    ./programs/cli-tools.nix
    ./programs/ssh.nix
  ];

  # XDG base directories
  xdg = {
    enable = true;
    cacheHome = "${config.home.homeDirectory}/.cache";
    configHome = "${config.home.homeDirectory}/.config";
    dataHome = "${config.home.homeDirectory}/.local/share";
    stateHome = "${config.home.homeDirectory}/.local/state";
  };

  # Universal packages (work everywhere)
  home.packages = with pkgs; [
    # Modern CLI tools
    eza
    bat
    ripgrep
    fd
    fzf
    zoxide
    delta
    direnv

    # Development
    git
    gh
    lazygit
    lazydocker

    # Utilities
    tldr
    htop
    tree
    jq
    wget
    curl
  ];

  # Let Home Manager manage itself
  programs.home-manager.enable = true;
}
```

**File: `~/nix-config/home/darwin.nix`**

```nix
{ config, pkgs, lib, ... }: {
  imports = [ ./common.nix ];

  home = {
    username = "mohamedmohamed";
    homeDirectory = "/Users/mohamedmohamed";
    stateVersion = "24.05";
  };

  # Config files using mkOutOfStoreSymlink (mutable!)
  xdg.configFile = {
    # Neovim - LazyVim can update freely
    "nvim".source = config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/dotfiles/nvim/.config/nvim";

    # ZSH - instant changes, no rebuild
    "zsh".source = config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/dotfiles/zsh/.config/zsh";

    # Karabiner
    "karabiner".source = config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/dotfiles/karabiner/.config/karabiner";

    # Aerospace
    "aerospace".source = config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/dotfiles/aerospace/.config/aerospace";

    # Borders
    "borders".source = config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/dotfiles/borders/.config/borders";

    # Sketchybar
    "sketchybar".source = config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/dotfiles/sketchybar/.config/sketchybar";

    # WezTerm
    "wezterm".source = config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/dotfiles/wezterm/.config/wezterm";
  };
}
```

**File: `~/nix-config/home/linux.nix`**

```nix
{ config, pkgs, lib, ... }: {
  imports = [ ./common.nix ];

  home = {
    username = "mohamed";
    homeDirectory = "/home/mohamed";
    stateVersion = "24.05";
  };

  # Same mkOutOfStoreSymlink approach
  xdg.configFile = {
    "nvim".source = config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/dotfiles/nvim/.config/nvim";

    "zsh".source = config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/dotfiles/zsh/.config/zsh";
  };
}
```

### Step 6: Program Configs

**File: `~/nix-config/home/programs/zsh.nix`**

```nix
{ config, pkgs, ... }: {
  programs.zsh = {
    enable = true;
    enableCompletion = true;

    # Performance-optimized completion (checks cache every 24h)
    completionInit = ''
      autoload -Uz compinit
      if [[ -n ${config.xdg.cacheHome}/zsh/.zcompdump(#qN.mh+24) ]]; then
        compinit -d ${config.xdg.cacheHome}/zsh/.zcompdump
      else
        compinit -C -d ${config.xdg.cacheHome}/zsh/.zcompdump
      fi
    '';

    # History
    history = {
      size = 100000;
      save = 100000;
      path = "${config.xdg.stateHome}/zsh/history";
      share = true;
      extended = true;
      ignoreDups = true;
      ignoreSpace = true;
    };

    # Shell aliases
    shellAliases = {
      # Modern CLI
      ls = "eza --icons";
      ll = "eza -l --icons --git";
      la = "eza -la --icons --git";
      lt = "eza --tree --level=2 --icons";
      cat = "bat";
      grep = "rg";
      find = "fd";

      # Git
      g = "git";
      gs = "git status";
      gc = "git commit";
      gp = "git push";
      gl = "git pull";

      # Nix
      rebuild = "darwin-rebuild switch --flake ~/nix-config#macbook";
      nix-clean = "nix-collect-garbage -d && darwin-rebuild switch --flake ~/nix-config#macbook";
    };

    # Plugins (replaces Antidote)
    plugins = [
      {
        name = "zsh-syntax-highlighting";
        src = pkgs.zsh-syntax-highlighting;
        file = "share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh";
      }
      {
        name = "zsh-autosuggestions";
        src = pkgs.zsh-autosuggestions;
        file = "share/zsh-autosuggestions/zsh-autosuggestions.zsh";
      }
      {
        name = "zsh-completions";
        src = pkgs.zsh-completions;
      }
      {
        name = "zsh-history-substring-search";
        src = pkgs.zsh-history-substring-search;
        file = "share/zsh-history-substring-search/zsh-history-substring-search.zsh";
      }
    ];

    # Performance optimization
    initExtra = ''
      # Skip global compinit (home-manager handles it)
      skip_global_compinit=1
    '';

    # Enable profiling for debugging (uncomment to diagnose slowness)
    # zprof.enable = true;
  };

  # NOTE: Actual ZSH config (vi mode, jk escape, cursor changes, etc.)
  # lives in ~/dotfiles/zsh/.config/zsh/.zshrc
  # Symlinked via mkOutOfStoreSymlink in darwin.nix/linux.nix
  # Edit that file → changes instant!
}
```

**File: `~/nix-config/home/programs/git.nix`**

```nix
{ pkgs, ... }: {
  programs.git = {
    enable = true;
    userName = "Mohamed Mohamed";
    userEmail = "your-email@example.com";

    aliases = {
      st = "status";
      co = "checkout";
      br = "branch";
      ci = "commit";
      amend = "commit --amend --no-edit";
      lg = "log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
    };

    extraConfig = {
      core = {
        editor = "nvim";
        pager = "delta";
        autocrlf = "input";
      };

      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;

      delta = {
        navigate = true;
        light = false;
        side-by-side = true;
        line-numbers = true;
        syntax-theme = "TwoDark";
      };

      interactive.diffFilter = "delta --color-only";
      merge.conflictstyle = "diff3";
      diff.colorMoved = "default";
    };
  };

  programs.gh = {
    enable = true;
    settings = {
      git_protocol = "ssh";
      prompt = "enabled";
    };
  };

  programs.lazygit.enable = true;
}
```

**File: `~/nix-config/home/programs/neovim.nix`**

```nix
{ pkgs, config, ... }: {
  # Nix ONLY manages the Neovim binary - Mason handles ALL LSPs!
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    # Only install utilities that Neovim uses (NOT LSPs!)
    # Mason manages ALL LSPs, formatters, linters
    extraPackages = with pkgs; [
      ripgrep  # Telescope search
      fd       # Telescope file picker
      gcc      # Treesitter compilation
    ];
  };

  # LazyVim config at ~/dotfiles/nvim/.config/nvim
  # Symlinked via mkOutOfStoreSymlink in darwin.nix/linux.nix
  #
  # "No Sacrifices" Benefits:
  # - Same Neovim version across Mac/Pi (Nix binary) ✅
  # - Mason manages ALL LSPs (works exactly as designed!) ✅
  # - :Mason install works perfectly ✅
  # - :Lazy update works perfectly ✅
  # - lazy-lock.json updates freely ✅
  # - Edit config → instant changes (no rebuild) ✅
  # - Zero interference from Nix ✅
}
```

**File: `~/nix-config/home/programs/starship.nix`**

```nix
{ pkgs, ... }: {
  programs.starship = {
    enable = true;
    enableZshIntegration = true;

    settings = {
      format = "$all";
      add_newline = false;
      scan_timeout = 10;
      command_timeout = 500;

      character = {
        success_symbol = "[➜](bold green)";
        error_symbol = "[➜](bold red)";
        vicmd_symbol = "[←](bold yellow)";
      };

      directory = {
        truncation_length = 3;
        truncate_to_repo = true;
        style = "bold cyan";
      };

      git_branch = {
        format = "[$symbol$branch]($style) ";
        symbol = " ";
        style = "bold purple";
      };

      git_status = {
        format = "([$all_status$ahead_behind]($style) )";
        style = "bold red";
      };

      nix_shell = {
        format = "[$symbol$state]($style) ";
        symbol = " ";
        style = "bold blue";
      };
    };
  };
}
```

**File: `~/nix-config/home/programs/cli-tools.nix`**

```nix
{ pkgs, ... }: {
  programs.eza = {
    enable = true;
    git = true;
    icons = true;
  };

  programs.bat = {
    enable = true;
    config = {
      theme = "TwoDark";
      pager = "less -FR";
    };
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;

    colors = {
      bg = "#1a1b26";
      "bg+" = "#292e42";
      fg = "#c0caf5";
      "fg+" = "#c0caf5";
      hl = "#7aa2f7";
      "hl+" = "#7dcfff";
    };

    defaultCommand = "fd --type f --hidden --exclude .git";
    fileWidgetCommand = "fd --type f";
    changeDirWidgetCommand = "fd --type d";

    defaultOptions = [
      "--height 40%"
      "--layout=reverse"
      "--border"
      "--inline-info"
    ];
  };

  programs.ripgrep = {
    enable = true;
    arguments = [
      "--max-columns=150"
      "--max-columns-preview"
      "--glob=!.git/*"
      "--smart-case"
      "--hidden"
    ];
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
    options = [ "--cmd cd" ];
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };
}
```

**File: `~/nix-config/home/programs/ssh.nix`**

```nix
{ config, ... }: {
  programs.ssh = {
    enable = true;

    extraConfig = ''
      AddKeysToAgent yes
      UseKeychain yes
      IdentityFile ~/.ssh/id_ed25519
    '';

    matchBlocks = {
      "github.com" = {
        hostname = "github.com";
        user = "git";
        identityFile = "~/.ssh/id_ed25519";
      };

      "raspberry-pi" = {
        hostname = "192.168.1.100";  # Update with actual Pi IP
        user = "mohamed";
        identityFile = "~/.ssh/id_ed25519";
        forwardAgent = true;
      };
    };
  };
}
```

### Step 7: First Build

```bash
cd ~/nix-config

# CRITICAL: Git add before building (flakes only see tracked files)
git add .

# First build
darwin-rebuild switch --flake ~/nix-config#macbook

# If successful
exec zsh

# Test
which eza bat rg fd nvim
eza --version
nvim --version

# Benchmark shell
time zsh -i -c exit
# Target: <100ms

# Commit
git commit -m "feat: initial Nix + Home Manager setup"
```

---

## Testing & Validation Strategies

### Before Deploying Changes

**Always test before deploying to avoid breaking your system!**

```bash
cd ~/nix-config

# 1. Check flake validity
nix flake check  # Validates all configurations

# 2. Build without activating
darwin-rebuild build --flake .#macbook  # Build, but don't apply

# 3. Dry-run to see what would change
darwin-rebuild switch --flake .#macbook --dry-activate  # Show changes

# 4. If everything looks good, actually deploy
darwin-rebuild switch --flake .#macbook
```

### Update Flake Inputs Safely

```bash
# Preview what will be updated
nix flake lock --update-input nixpkgs --print-commit-graph

# Update and see diff
nix flake update
git diff flake.lock  # Review changes

# Test build before switching
darwin-rebuild build --flake .#macbook
```

---

## mkOutOfStoreSymlink Gotchas

### Critical Requirements

**1. MUST Use Absolute Paths**

```nix
# ❌ Won't work - relative path
"nvim".source = config.lib.file.mkOutOfStoreSymlink "dotfiles/nvim/.config/nvim";

# ✅ Works - absolute path via config variable
"nvim".source = config.lib.file.mkOutOfStoreSymlink
  "${config.home.homeDirectory}/dotfiles/nvim/.config/nvim";
```

**2. Risk of Dangling Symlinks**

The function doesn't verify the target exists! If you delete/move the source, you'll have broken symlinks.

```bash
# Check for broken symlinks
ls -la ~/.config/nvim  # Should point to ~/dotfiles, not /nix/store
```

**3. Rare Mason Lockfile Issues**

Some users reported Mason (Neovim LSP installer) having lockfile errors with mkOutOfStoreSymlink. This is uncommon but worth noting.

**Workaround:** Install utilities (ripgrep, fd, gcc) via Nix, let Mason handle LSPs (which is what our config does!).

---

## Common Pitfalls & Solutions

### Path Issues

**Problem:** Nix packages shadow Homebrew
**Solution:** Check `which` shows /nix/store paths. Nix should be earlier in PATH (home-manager handles this automatically).

```bash
which eza  # Should show /nix/store/...
```

### Homebrew Conflicts

**Problem:** Both Nix and Homebrew install the same package
**Solution:** Use `homebrew.onActivation.cleanup = "zap"` to remove unmanaged brews (already in our config!).

### Flake Git Tracking

**Problem:** Changes not picked up by nix build
**Cause:** Flakes only see git-tracked files
**Solution:** Always `git add .` before building

```bash
git add .
darwin-rebuild switch --flake .#macbook
```

### Build Failures on First Try

**Problem:** `Package 'foo' has an unfree license`
**Solution:** Add `nixpkgs.config.allowUnfree = true` (already in our config!).

### Garbage Collection Issues

**Problem:** After `nix-collect-garbage -d`, boot entries aren't updated
**Solution:** Rebuild after GC to update boot entries:

```bash
nix-collect-garbage -d
darwin-rebuild switch --flake ~/nix-config#macbook  # Updates boot entries
```

---

## Performance Benchmarks

### Expected Shell Startup Times

```bash
# Test with hyperfine
hyperfine --warmup 3 'zsh -i -c exit'
```

**Target Times:**
- **Cold start (first shell):** 100-150ms (acceptable)
- **Warm start (subsequent shells):** 50-80ms (target)
- **CI environment:** 150-250ms (slower, acceptable)

### Nix Build Times

**Initial build:** 5-15 minutes (downloads + compilation)
**Incremental rebuild:** 30-60 seconds (cached packages)
**Flake update:** 1-3 minutes (mostly downloads)

### Profiling Commands

```bash
# ZSH startup time
time zsh -i -c exit

# Detailed profiling (add to .zshrc temporarily)
zmodload zsh/zprof
# ... your config ...
zprof  # Run this in shell to see profile

# Nix build time
time darwin-rebuild build --flake .#macbook
```

### If Shell is Slow (>200ms)

```nix
# Enable profiling in home/programs/zsh.nix
programs.zsh.zprof.enable = true;
```

Then run `zprof` in your shell to see what's slow.

---

## Daily Workflow

### Making Changes

**Instant Changes (no rebuild needed):**
```bash
# Edit configs in ~/dotfiles (mkOutOfStoreSymlink)
nvim ~/dotfiles/nvim/.config/nvim/init.lua
nvim ~/dotfiles/zsh/.config/zsh/.zshrc

# Changes reflect INSTANTLY
# LazyVim :Lazy update works perfectly
```

**Declarative Changes (requires rebuild):**
```bash
# Edit Nix configs
nvim ~/nix-config/home/programs/git.nix

cd ~/nix-config
git add .
darwin-rebuild switch --flake .#macbook

git commit -m "feat: update git config"
```

### Updating Packages

```bash
cd ~/nix-config

# Update all flake inputs
nix flake update

# Or specific input
nix flake lock --update-input nixpkgs

# Rebuild
darwin-rebuild switch --flake .#macbook

# Commit lock file
git add flake.lock
git commit -m "chore: update flake inputs"
```

### Rollback

```bash
# List generations
darwin-rebuild --list-generations

# Rollback to previous
darwin-rebuild switch --rollback

# Rollback to specific
darwin-rebuild switch --switch-generation 42
```

---

## Raspberry Pi Setup

### Option 1: Build SD Card Image (Recommended)

With raspberry-pi-nix, you can build a custom SD card image with your configuration already baked in!

```bash
cd ~/nix-config

# Build SD card image
nix build '.#nixosConfigurations.raspberry-pi.config.system.build.sdImage'

# Flash to SD card (replace diskX with your SD card device)
sudo dd if=result/sd-image/nixos-*.img of=/dev/diskX bs=1m status=progress

# Eject and boot Pi
```

**Benefits:**
- Pi boots directly into your configured system
- No manual setup needed
- Same configuration as your Mac (via flake.lock)

### Option 2: Standard NixOS Installation

1. Download NixOS ARM64 image from https://nixos.org/download.html
2. Flash to SD card
3. Boot Pi

### Generate Hardware Config

```bash
# SSH to Pi
ssh nixos@<pi-ip>  # Password: empty

# Generate
sudo nixos-generate-config --show-hardware-config > /tmp/hardware-configuration.nix

# Copy to Mac
# From Mac:
scp nixos@<pi-ip>:/tmp/hardware-configuration.nix ~/nix-config/hosts/raspberry-pi/
```

### Create Pi Config

**File: `~/nix-config/hosts/raspberry-pi/default.nix`**

```nix
{ config, pkgs, ... }: {
  imports = [
    ./hardware-configuration.nix
  ];

  # Raspberry Pi 5 specific configuration
  raspberry-pi-nix.board = "bcm2712";  # Pi 5

  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = false;
  };

  networking = {
    hostName = "raspberry-pi";
    networkmanager.enable = true;
  };

  time.timeZone = "America/Los_Angeles";

  users.users.mohamed = {
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 YOUR_PUBLIC_KEY"  # From ~/.ssh/id_ed25519.pub on Mac
    ];
  };

  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;
  };

  nix.settings = {
    experimental-features = "nix-command flakes";
    auto-optimise-store = true;

    # Binary caches (avoid compiling kernel!)
    substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
  };

  # Automatic garbage collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  environment.systemPackages = with pkgs; [
    vim
    git
  ];

  system.stateVersion = "24.05";
}
```

### Deploy from Mac

```bash
cd ~/nix-config

git add hosts/raspberry-pi/

# Deploy remotely
nixos-rebuild switch --flake .#raspberry-pi \
  --target-host mohamed@<pi-ip> \
  --use-remote-sudo

git commit -m "feat: add Raspberry Pi configuration"
```

### Set Up Dotfiles on Pi

```bash
# SSH to Pi
ssh mohamed@<pi-ip>

# Clone dotfiles
git clone <your-dotfiles-repo> ~/dotfiles

# mkOutOfStoreSymlink will automatically link configs
```

### Verify Identical Environments

```bash
# On Mac
eza --version
bat --version
nvim --version

# On Pi
eza --version
bat --version
nvim --version

# Should be IDENTICAL (same flake.lock)
```

---

## Secrets Management

### Set Up sops-nix

```bash
# Generate age key
nix shell nixpkgs#age
mkdir -p ~/.config/sops/age
age-keygen -o ~/.config/sops/age/keys.txt

# View public key (for .sops.yaml)
cat ~/.config/sops/age/keys.txt | grep "public key:"
```

### Configure

**File: `~/nix-config/secrets/.sops.yaml`**

```yaml
keys:
  - &me age1xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

creation_rules:
  - path_regex: secrets/secrets\.yaml$
    key_groups:
      - age:
          - *me
```

### Create & Encrypt Secrets

```bash
cd ~/nix-config/secrets

# Create
cat > secrets.yaml << 'EOF'
openai_api_key: sk-your-key
EOF

# Encrypt
nix shell nixpkgs#sops -c sops -e secrets.yaml > secrets.yaml.enc
mv secrets.yaml.enc secrets.yaml
```

> Note: Do not add `anthropic_api_key` here—leaving `ANTHROPIC_API_KEY` unset keeps Claude Code on the Max plan instead of billing the API.

### Configure in Home Manager

Add to `home/common.nix`:

```nix
sops = {
  age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
  defaultSopsFile = ../secrets/secrets.yaml;

  secrets = {
    openai_api_key = {
      path = "${config.home.homeDirectory}/.secrets/openai";
    };
  };
};
```

Add to `home/programs/zsh.nix`:

```nix
programs.zsh = {
  # ... existing config

  initExtra = ''
    export OPENAI_API_KEY="$(cat ~/.secrets/openai 2>/dev/null || echo "")"
  '';
};
```

### Verify

```bash
# Rebuild
darwin-rebuild switch --flake ~/nix-config#macbook

# Check secrets loaded
echo $OPENAI_API_KEY

# CRITICAL: Verify NOT in /nix/store
nix-store --query --references /run/current-system | grep -i secret
# Should return nothing!
```

---

## Success Criteria

- ✅ Shell startup <100ms on both machines
- ✅ Same tool versions (verified via `--version`)
- ✅ LazyVim updates work (`:Lazy update` no errors)
- ✅ Instant config changes for nvim/zsh (mkOutOfStoreSymlink)
- ✅ Declarative system settings (macOS defaults)
- ✅ Secrets encrypted, not in /nix/store
- ✅ One command updates: `darwin-rebuild switch --flake .#macbook`
- ✅ Instant rollback: `darwin-rebuild switch --rollback`

---

## Troubleshooting

### Build Errors

**Error: "getting status of '/nix/store/.../foo.nix': No such file"**
- **Cause:** Flakes only see git-tracked files
- **Fix:** `git add <file>` before building

**Error: "infinite recursion encountered"**
- **Cause:** Circular imports
- **Fix:** Check module imports, avoid self-references

**Error: "Package 'foo' has an unfree license"**
- **Fix:** Add to config: `nixpkgs.config.allowUnfree = true;`

### Performance Issues

**Shell startup >100ms**
- Profile: Add `zmodload zsh/zprof` to .zshrc, run `zprof`
- Fix: Lazy-load heavy plugins

**Slow Nix builds**
- Enable binary cache (should be default)
- Check: `nix-store --verify --check-contents`

### LazyVim Issues

**lazy-lock.json not updating**
- Check: `xdg.configFile."nvim"` uses `mkOutOfStoreSymlink`
- Verify: `ls -la ~/.config/nvim` (should point to ~/dotfiles, not /nix/store)

**Neovim can't find LSPs**
- Check: LSPs in `programs.neovim.extraPackages`
- Verify: `which lua-language-server` shows Nix path

### Secrets Issues

**Secrets in /nix/store**
- Check: `nix-store --query --references /run/current-system | grep secret`
- Fix: Use sops-nix properly, never put secrets in .nix files

**Can't decrypt**
- Check: Age key exists at `~/.config/sops/age/keys.txt`
- Verify: Public key in `.sops.yaml` matches

---

## Resources

### Official Documentation
- [Nix Manual](https://nix.dev/)
- [Home Manager Manual](https://nix-community.github.io/home-manager/)
- [nix-darwin Manual](https://daiderd.com/nix-darwin/manual/)
- [NixOS & Flakes Book](https://nixos-and-flakes.thiscute.world/)

### Critical Tools
- **[nix-homebrew](https://github.com/zhaofengli/nix-homebrew)** - Seamless Homebrew migration
- **[raspberry-pi-nix](https://github.com/nix-community/raspberry-pi-nix)** - Raspberry Pi support with pre-built kernels
- **[nix-community cachix](https://nix-community.cachix.org)** - Binary cache for community packages

### Example Repositories
- [WTanardi/nix-config](https://github.com/WTanardi/nix-config) - ZSH + Neovim + Starship (perfect match!)
- [breuerfelix/dotfiles](https://github.com/breuerfelix/dotfiles) - macOS + nix-darwin (external nvim config)
- [appaquet/dotfiles](https://github.com/appaquet/dotfiles) - Cross-platform NixOS + macOS
- [gesi/dotfiles](https://github.com/gesi/dotfiles) - Nix + Homebrew hybrid
- [zmre/aerospace-sketchybar-nix-lua-config](https://github.com/zmre/aerospace-sketchybar-nix-lua-config) - AeroSpace + SketchyBar working example

### Articles & Guides (2024-2025)
- [Jean-Charles Quillet - mkOutOfStoreSymlink](https://jeancharles.quillet.org/posts/2023-02-07-The-home-manager-function-that-changes-everything.html)
- [Davis Haupt - Managing dotfiles on macOS with Nix](https://davi.sh/blog/2024/02/nix-home-manager/)
- [Evan Travers - Switching to nix-darwin and Flakes](https://evantravers.com/articles/2024/02/06/switching-to-nix-darwin-and-flakes/)
- [Farid Zakaria - NixOS, Raspberry Pi & Me (Aug 2024)](https://fzakaria.com/2024/08/13/nixos-raspberry-pi-me)
- [Ian Henry - Switching from Homebrew to Nix](https://ianthehenry.com/posts/how-to-learn-nix/switching-from-homebrew-to-nix/)
- [Managing mutable files in NixOS](https://www.foodogsquared.one/posts/2023-03-24-managing-mutable-files-in-nixos/)

### Community
- [NixOS Discourse](https://discourse.nixos.org/)
- [NixOS Wiki](https://nixos.wiki/)
- [r/NixOS](https://reddit.com/r/nixos)

---

## Next Steps

1. **Review this document** - Understand the architecture
2. **Install Nix** - Use Determinate Systems installer
3. **Read examples** - Study WTanardi and breuerfelix repos
4. **Start Phase 1** - Create basic flake, first build
5. **Iterate** - Add programs gradually, test thoroughly

**Ready to achieve perfect reproducibility?**

---

**Document Version:** 2.0
**Last Updated:** 2025-01-03
**Status:** Research Complete - Production Ready

**Changelog:**
- v2.0 (2025-01-03): Added nix-homebrew, raspberry-pi-nix, comprehensive LazyVim "no sacrifices" approach, testing strategies, gotchas, performance benchmarks, and 2024-2025 best practices
- v1.0 (2025-01-02): Initial research and planning
