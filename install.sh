#!/usr/bin/env bash
set -e

# Detect OS
if [[ "$OSTYPE" == "darwin"* ]]; then
    PLATFORM="darwin"
else
    PLATFORM="linux"
fi

USERNAME=$(whoami)

echo "Setting up for ${USERNAME} on ${PLATFORM}"

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
        nix run nix-darwin -- switch --flake .#${USERNAME}@mac
        
        echo ""
        echo "✓ nix-darwin installed successfully!"
        echo ""
        echo "Future updates: darwin-rebuild switch --flake ~/.config/home-manager#${USERNAME}@mac"
    else
        echo "nix-darwin already installed, updating configuration..."
        darwin-rebuild switch --flake .#${USERNAME}@mac
    fi
    
else
    echo "Installing home-manager for Linux..."
    
    # First-time home-manager installation
    if ! command -v home-manager &> /dev/null; then
        echo "Running initial home-manager setup..."
        nix run home-manager/master -- switch --flake .#${USERNAME}@linux
        
        echo ""
        echo "✓ home-manager installed successfully!"
        echo ""
        echo "Future updates: home-manager switch --flake ~/.config/home-manager#${USERNAME}@linux"
    else
        echo "home-manager already installed, updating configuration..."
        home-manager switch --flake .#${USERNAME}@linux
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
    echo "  darwin-rebuild switch --flake ~/.config/home-manager#${USERNAME}@mac"
else
    echo "To update in the future, run:"
    echo "  home-manager switch --flake ~/.config/home-manager#${USERNAME}@linux"
fi
