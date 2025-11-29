{ config, pkgs, ... }:

{
  imports = [
    ../home-darwin.nix

  ];

  # macOS work specific configuration
  programs.zsh.shellAliases = {
    hm = "sudo -H nix run nix-darwin/master#darwin-rebuild -- switch --flake ~/.config/home-manager#thomas@mac-work; exec zsh";
    drs = "sudo -H nix run nix-darwin/master#darwin-rebuild -- switch --flake ~/.config/home-manager#thomas@mac-work; exec zsh";
    hm-clean = "sudo nix-env --delete-generations +1 --profile /nix/var/nix/profiles/system; nix store gc; nix store optimise";
  };

  # Example: Work-specific packages (corporate VPN, work tools, etc.)
}
