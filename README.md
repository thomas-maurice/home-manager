# `home-manager` configuration

## install

First install nix if not done yet:
```
sh <(curl -L https://nixos.org/nix/install) --daemon
```

Then enable flakes:
```
mkdir -p ~/.config/nix
if ! grep -q "experimental-features" ~/.config/nix/nix.conf 2>/dev/null; then
    echo "experimental-features = nix-command flakes" >> ~/.config/nix/nix.conf
fi
```

Then apply the config:
```
nix run home-manager/latest -- switch --flake .#thomas@platform
```

Source the home manager envs in your .zshrc:
```
source $HOME/.nix-profile/etc/profile.d/hm-session-vars.sh
```

Then restart your shell

## Cleanup
```
home-manager expire-generations "-7 days"
nix-env --delete-generations old
nix store gc --dry-run
nix store optimise
```
