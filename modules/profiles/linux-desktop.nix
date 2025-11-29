{ config, pkgs, ... }:

{
  imports = [
    ../home-linux.nix

  ];

  # Linux desktop specific configuration
  programs.zsh.shellAliases = {
    hm = "home-manager switch --flake ~/.config/home-manager#thomas@linux-desktop; exec zsh";
    hm-clean = "home-manager expire-generations '-0 days'; nix-env --delete-generations old; nix store gc; nix store optimise";
  };

  # Example: Enable gaming packages, desktop-specific settings, etc.
}
