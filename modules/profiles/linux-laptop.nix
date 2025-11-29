{ config, pkgs, ... }:

{
  imports = [
    ../home-linux.nix

  ];

  # Linux laptop specific configuration
  programs.zsh.shellAliases = {
    hm = "home-manager switch --flake ~/.config/home-manager#thomas@linux-laptop; exec zsh";
    hm-clean = "home-manager expire-generations '-0 days'; nix-env --delete-generations old; nix store gc; nix store optimise";
  };

  # Example: Enable battery optimizations, laptop-specific settings, etc.
}
