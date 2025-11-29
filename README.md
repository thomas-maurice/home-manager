# `home-manager` configuration

Declarative dotfiles and system configuration using Nix, home-manager, and nix-darwin.

## Quick Install

**macOS Prerequisites:**

Before running the installer, you must install Xcode Command Line Tools:
```bash
xcode-select --install
```

The installation script handles everything automatically:

```bash
./install.sh
```

This will:
- Install Nix (if not already installed)
- Enable flakes
- Set up nix-darwin (macOS) or home-manager (Linux)
- Apply your configuration

After installation, restart your shell:
```bash
exec $SHELL
```

## What's Included

- **Shell configuration**: zsh with oh-my-zsh and powerlevel10k
- **Neovim config**: Auto-cloned from https://github.com/thomas-maurice/nvim-config
- **System packages**: Declaratively managed via Nix
- **macOS settings**: System defaults, trackpad, dark mode, etc.
- **Homebrew integration**: Casks and App Store apps via nix-darwin

## Profiles

This configuration supports multiple profiles for different machines:

**Linux:**
- `thomas@linux-laptop` - Linux laptop configuration
- `thomas@linux-desktop` - Linux desktop configuration

**macOS:**
- `thomas@mac-work` - macOS work laptop
- `thomas@mac-personal` - macOS personal laptop

The install script automatically detects and selects the appropriate profile.

## Daily Usage

After initial setup, use these aliases:

- `hm` - Rebuild your system configuration (uses correct profile automatically)
- `hmu` - Update flake dependencies
- `hm-clean` - Clean up old generations and optimize Nix store

### Manual Commands

**macOS work:**
```bash
darwin-rebuild switch --flake ~/.config/home-manager#thomas@mac-work
```

**macOS personal:**
```bash
darwin-rebuild switch --flake ~/.config/home-manager#thomas@mac-personal
```

**Linux laptop:**
```bash
home-manager switch --flake ~/.config/home-manager#thomas@linux-laptop
```

**Linux desktop:**
```bash
home-manager switch --flake ~/.config/home-manager#thomas@linux-desktop
```

## Manual Cleanup

If you prefer to run cleanup commands manually instead of using `hm-clean`:

```bash
# Remove old generations (keep last 7 days)
home-manager expire-generations "-7 days"

# Delete old Nix generations
nix-env --delete-generations old

# Garbage collect unused packages
nix store gc

# Optimize Nix store
nix store optimise
```

## Configuration Structure

```
.
├── flake.nix                    # Main flake configuration (defines all profiles)
├── flake.lock                   # Locked dependency versions
├── install.sh                   # Automated installation script
├── darwin/
│   └── configuration.nix        # macOS-specific system settings (nix-darwin)
└── modules/
    ├── home-base.nix            # Base config shared across ALL systems
    ├── home-linux.nix           # Linux-specific base config
    ├── home-darwin.nix          # macOS-specific base config
    ├── profiles/                # Profile-specific configurations
    │   ├── linux-laptop.nix     # Linux laptop profile
    │   ├── linux-desktop.nix    # Linux desktop profile
    │   ├── darwin-work.nix      # macOS work profile
    │   └── darwin-personal.nix  # macOS personal profile
    └── packages/
        ├── common.nix           # Cross-platform packages
        ├── darwin.nix           # macOS-specific packages
        ├── linux.nix            # Linux-specific packages
        ├── gui.nix              # GUI applications
        ├── asdf/
        │   └── default.nix      # asdf version manager configuration
        ├── neovim/
        │   └── default.nix      # Neovim configuration
        ├── ssh-gpg-agent/
        │   └── default.nix      # GPG agent + SSH configuration
        └── shell/
            ├── default.nix      # Shell configuration (zsh, aliases, etc.)
            ├── ghostty.config   # Ghostty terminal config
            ├── p10k.zsh         # Powerlevel10k theme config
            ├── tmux.conf        # tmux configuration
            └── zellij-config.kdl # Zellij configuration
```

### Adding a New Profile

1. Create a new profile file in `modules/profiles/` (e.g., `my-machine.nix`)
2. Import the appropriate base (`home-linux.nix` or `home-darwin.nix`)
3. Add profile-specific packages and settings
4. Define the `hm` alias to point to the correct flake output
5. Add the profile to `flake.nix` under `homeConfigurations` or `darwinConfigurations`
