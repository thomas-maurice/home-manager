{ config, pkgs, ... }:

{
  imports = [
    ../home-darwin.nix
  ];

  # macOS work specific configuration
  programs.zsh.shellAliases = {
    hm = "sudo -H nix run nix-darwin/master#darwin-rebuild -- switch --flake ~/.config/home-manager#thomas@mac-work; exec zsh";
    hmn = "home-manager news --flake ~/.config/home-manager#thomas@mac-work";
    drs = "sudo -H nix run nix-darwin/master#darwin-rebuild -- switch --flake ~/.config/home-manager#thomas@mac-work; exec zsh";
  };

  # Example: Work-specific packages (corporate VPN, work tools, etc.)
}
