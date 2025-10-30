#!/usr/bin/env bash
set -e

# Detect OS
if [[ "$OSTYPE" == "darwin"* ]]; then
    PLATFORM="darwin"
else
    PLATFORM="linux"
fi

# Detect hostname
HOSTNAME=$(hostname -s)
USERNAME=$(whoami)

echo "Setting up Home Manager for ${USERNAME}@${PLATFORM}"

# Install Nix if needed
if ! command -v nix &> /dev/null; then
    echo "Installing Nix..."
    sh <(curl -L https://nixos.org/nix/install) --daemon
fi

# Enable flakes
mkdir -p ~/.config/nix
if ! grep -q "experimental-features" ~/.config/nix/nix.conf 2>/dev/null; then
    echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
fi

# Apply configuration
echo "Applying Home Manager configuration..."
nix run home-manager/latest -- switch --flake .#${USERNAME}@${PLATFORM}

echo "Done! Restart your shell or run: exec \$SHELL"
