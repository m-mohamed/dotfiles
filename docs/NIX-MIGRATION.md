# Nix + Home Manager Migration Plan

**Status:** Research & Planning Phase
**Goal:** Perfect cross-platform reproducibility (M1 Mac + Raspberry Pi 5)
**Current:** Homebrew + GNU Stow
**Target:** Nix + Home Manager

---

## Executive Summary

This document outlines the complete migration from Homebrew + GNU Stow to Nix + Home Manager based on comprehensive research of best practices, real-world examples, and solutions to common pitfalls.

### Key Decision: Full Migration is Viable

After reviewing the concerns from developers who left Nix (notably the video about returning to Stow), we discovered **`mkOutOfStoreSymlink`** - a built-in Home Manager function that solves all the major issues:

- ✅ LazyVim lock file updates work (no rebuild needed)
- ✅ Instant config changes for frequently-edited files
- ✅ No file ownership problems
- ✅ Still get cross-platform package reproducibility

### Why This Works for Our Use Case

**Different from the video creator:**
- We have **2 machines** (M1 Mac + Pi) → Nix's cross-platform is essential
- They had **1 machine** (macOS only) → Stow was sufficient
- We need **identical tool versions** across platforms → Nix's flake.lock crucial
- They didn't need cross-platform → No benefit from Nix's reproducibility

---

## Research Findings

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

**Consensus:** LazyVim doesn't work smoothly with pure Nix, but `mkOutOfStoreSymlink` is the best compromise.

**Recommended Approach:**
```nix
# home/programs/neovim.nix
{ pkgs, config, ... }: {
  # Nix manages the binary and dependencies
  programs.neovim = {
    enable = true;
    extraPackages = with pkgs; [
      lua-language-server
      nil  # Nix LSP
      ripgrep
      fd
    ];
  };

  # LazyVim config is mutable (mkOutOfStoreSymlink)
  xdg.configFile."nvim".source = config.lib.file.mkOutOfStoreSymlink
    "${config.home.homeDirectory}/dotfiles/nvim/.config/nvim";
}
```

**Result:**
- ✅ Same neovim version across Mac/Pi (Nix manages binary)
- ✅ LazyVim can update `lazy-lock.json` freely
- ✅ Edit config → instant reflection (no rebuild)
- ✅ LSPs/formatters installed via Nix (reproducible)

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

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, nix-darwin, home-manager, sops-nix }: {
    # macOS configuration
    darwinConfigurations."macbook" = nix-darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      modules = [
        ./hosts/macbook
        home-manager.darwinModules.home-manager
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

    # Raspberry Pi configuration
    nixosConfigurations."raspberry-pi" = nixpkgs.lib.nixosSystem {
      system = "aarch64-linux";
      modules = [
        ./hosts/raspberry-pi
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

  # Nix settings
  nix = {
    settings = {
      experimental-features = "nix-command flakes";
      auto-optimise-store = true;
      trusted-users = [ "@admin" ];
    };

    gc = {
      automatic = true;
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

    keyboard = {
      enableKeyMapping = true;
      remapCapsLockToEscape = true;
    };
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
  homebrew = {
    enable = true;

    onActivation = {
      autoUpdate = false;
      cleanup = "zap";
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
      "karabiner-elements"
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

    # Performance-optimized completion
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
      nix-clean = "nix-collect-garbage -d && nix-store --gc";
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
  };

  # NOTE: Actual ZSH config (vi mode, jk escape, cursor changes, etc.)
  # lives in ~/dotfiles/zsh/.config/zsh/.zshrc
  # Symlinked via mkOutOfStoreSymlink in darwin.nix
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
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    # Install LSPs, formatters via Nix (reproducible)
    extraPackages = with pkgs; [
      # Language servers
      lua-language-server
      nil  # Nix LSP
      nodePackages.typescript-language-server
      nodePackages.vscode-langservers-extracted

      # Formatters
      stylua
      nixpkgs-fmt
      nodePackages.prettier

      # Tools
      ripgrep  # Telescope
      fd       # Telescope
      gcc      # Treesitter
    ];
  };

  # LazyVim config at ~/dotfiles/nvim/.config/nvim
  # Symlinked via mkOutOfStoreSymlink in darwin.nix
  #
  # Benefits:
  # - LazyVim can update lazy-lock.json ✅
  # - Edit config → instant changes ✅
  # - No rebuild needed ✅
  # - Same nvim version across Mac/Pi (Nix binary) ✅
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

### Install NixOS

1. Download NixOS ARM64 image
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
  imports = [ ./hardware-configuration.nix ];

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
anthropic_api_key: sk-ant-your-key
EOF

# Encrypt
nix shell nixpkgs#sops -c sops -e secrets.yaml > secrets.yaml.enc
mv secrets.yaml.enc secrets.yaml
```

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
    anthropic_api_key = {
      path = "${config.home.homeDirectory}/.secrets/anthropic";
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
    export ANTHROPIC_API_KEY="$(cat ~/.secrets/anthropic 2>/dev/null || echo "")"
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

### Example Repositories
- [WTanardi/nix-config](https://github.com/WTanardi/nix-config) - ZSH + Neovim + Starship
- [breuerfelix/dotfiles](https://github.com/breuerfelix/dotfiles) - macOS + nix-darwin
- [appaquet/dotfiles](https://github.com/appaquet/dotfiles) - Cross-platform
- [gesi/dotfiles](https://github.com/gesi/dotfiles) - Nix + Homebrew hybrid

### Articles & Guides
- [Jean-Charles Quillet - mkOutOfStoreSymlink](https://jeancharles.quillet.org/posts/2023-02-07-The-home-manager-function-that-changes-everything.html)
- [Davis Haupt - Managing dotfiles on macOS with Nix](https://davi.sh/blog/2024/02/nix-home-manager/)
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

**Document Version:** 1.0
**Last Updated:** 2025-01-02
**Status:** Ready for Implementation
