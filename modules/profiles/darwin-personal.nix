{ config, pkgs, ... }:

{
  imports = [
    ../home-darwin.nix

  ];

  # macOS personal specific configuration
  programs.zsh.shellAliases = {
    hm = "sudo -H nix run nix-darwin/master#darwin-rebuild -- switch --flake ~/.config/home-manager#thomas@mac-personal; exec zsh";
    drs = "sudo -H nix run nix-darwin/master#darwin-rebuild -- switch --flake ~/.config/home-manager#thomas@mac-personal; exec zsh";
    hm-clean = "sudo nix-env --delete-generations +1 --profile /nix/var/nix/profiles/system; nix store gc; nix store optimise";
  };

  # Example: Personal packages (games, media tools, etc.)
}
