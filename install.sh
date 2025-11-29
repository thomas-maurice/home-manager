#!/usr/bin/env bash
set -e

# Detect OS
if [[ "$OSTYPE" == "darwin"* ]]; then
    PLATFORM="darwin"
else
    PLATFORM="linux"
fi

USERNAME=$(whoami)

# Detect profile based on platform and user input
detect_profile() {
    if [[ "$PLATFORM" == "darwin" ]]; then
        echo ""
        echo "Is this a work or personal Mac?"
        echo "1) Work"
        echo "2) Personal"
        read -p "Choose [1-2]: " choice
        case $choice in
            1) PROFILE="mac-work" ;;
            2) PROFILE="mac-personal" ;;
            *) echo "Invalid choice, defaulting to personal"; PROFILE="mac-personal" ;;
        esac
    else
        # Auto-detect Linux profile based on system type
        if [[ -f /sys/class/power_supply/BAT0/status ]] || [[ -f /sys/class/power_supply/BAT1/status ]]; then
            PROFILE="linux-laptop"
            echo "Detected laptop (battery found)"
        else
            PROFILE="linux-desktop"
            echo "Detected desktop (no battery found)"
        fi

        # Allow override
        echo ""
        echo "Detected profile: $PROFILE"
        read -p "Is this correct? [Y/n]: " confirm
        if [[ "$confirm" =~ ^[Nn]$ ]]; then
            echo "1) linux-laptop"
            echo "2) linux-desktop"
            read -p "Choose [1-2]: " choice
            case $choice in
                1) PROFILE="linux-laptop" ;;
                2) PROFILE="linux-desktop" ;;
                *) echo "Invalid choice, using detected profile" ;;
            esac
        fi
    fi

    echo ""
    echo "Using profile: ${USERNAME}@${PROFILE}"
}

detect_profile
echo "Setting up for ${USERNAME} on ${PLATFORM} (profile: ${PROFILE})"

# Install Nix if needed
if ! command -v nix &> /dev/null; then
    echo "Installing Nix..."
    sh <(curl -L https://nixos.org/nix/install) --daemon
    
    # Source nix after installation
    if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
        . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
    fi
fi

# Enable flakes
mkdir -p ~/.config/nix
if ! grep -q "experimental-features" ~/.config/nix/nix.conf 2>/dev/null; then
    echo "Enabling flakes..."
    echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
fi

# Platform-specific installation
if [[ "$PLATFORM" == "darwin" ]]; then
    echo "Installing nix-darwin with home-manager..."

    # First-time nix-darwin installation
    if ! command -v darwin-rebuild &> /dev/null; then
        echo "Running initial nix-darwin setup..."
        nix run nix-darwin -- switch --flake .#${USERNAME}@${PROFILE}

        echo ""
        echo "✓ nix-darwin installed successfully!"
        echo ""
        echo "Future updates: darwin-rebuild switch --flake ~/.config/home-manager#${USERNAME}@${PROFILE}"
        echo "Or simply run: hm"
    else
        echo "nix-darwin already installed, updating configuration..."
        darwin-rebuild switch --flake .#${USERNAME}@${PROFILE}
    fi

else
    echo "Installing home-manager for Linux..."

    # First-time home-manager installation
    if ! command -v home-manager &> /dev/null; then
        echo "Running initial home-manager setup..."
        nix run home-manager/master -- switch --flake .#${USERNAME}@${PROFILE}

        echo ""
        echo "✓ home-manager installed successfully!"
        echo ""
        echo "Future updates: home-manager switch --flake ~/.config/home-manager#${USERNAME}@${PROFILE}"
        echo "Or simply run: hm"
    else
        echo "home-manager already installed, updating configuration..."
        home-manager switch --flake .#${USERNAME}@${PROFILE}
    fi
fi

echo ""
echo "================================================"
echo "Setup complete!"
echo "================================================"
echo ""
echo "Restart your shell or run: exec \$SHELL"
echo ""

if [[ "$PLATFORM" == "darwin" ]]; then
    echo "To update in the future, run:"
    echo "  darwin-rebuild switch --flake ~/.config/home-manager#${USERNAME}@${PROFILE}"
    echo "Or simply: hm"
else
    echo "To update in the future, run:"
    echo "  home-manager switch --flake ~/.config/home-manager#${USERNAME}@${PROFILE}"
    echo "Or simply: hm"
fi
