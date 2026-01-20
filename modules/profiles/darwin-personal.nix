{ config, pkgs, ... }:

{
  imports = [
    ../home-darwin.nix
    ../packages/profiles/darwin-personal.nix
  ];

  # macOS personal specific configuration
  programs.zsh.shellAliases = {
    hm = "sudo -H nix run nix-darwin/master#darwin-rebuild -- switch --flake ~/.config/home-manager#thomas@mac-personal; exec zsh";
    hmn = "home-manager news --flake ~/.config/home-manager#thomas@mac-personal";
    drs = "sudo -H nix run nix-darwin/master#darwin-rebuild -- switch --flake ~/.config/home-manager#thomas@mac-personal; exec zsh";
  };
}
