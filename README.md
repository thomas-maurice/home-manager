# `home-manager` configuration

Declarative dotfiles and system configuration using Nix, home-manager, and nix-darwin.

## Quick Install

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

## Daily Usage

After initial setup, use these aliases:

- `hm` - Rebuild your system configuration
- `hmu` - Update flake dependencies
- `hm-clean` - Clean up old generations and optimize Nix store

### Manual Commands

**macOS:**
```bash
darwin-rebuild switch --flake ~/.config/home-manager#thomas@mac
```

**Linux:**
```bash
home-manager switch --flake ~/.config/home-manager#thomas@linux
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
├── flake.nix                    # Main flake configuration
├── flake.lock                   # Locked dependency versions
├── darwin/
│   └── configuration.nix        # macOS-specific settings (nix-darwin)
└── modules/
    ├── home.nix                 # Home-manager entry point
    └── packages/
        ├── common.nix           # Cross-platform packages
        ├── darwin.nix           # macOS-specific packages
        ├── linux.nix            # Linux-specific packages
        ├── gui.nix              # GUI applications
        └── shell/               # Shell configuration (zsh, aliases, etc.)
```
