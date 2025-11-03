{ config, pkgs, ... }:

{
  # Linux-only packages
  home.packages = with pkgs; [
    curl
  ];

  fonts.packages = with pkgs; [
    pkgs.nerd-fonts.jetbrains-mono
    pkgs.nerd-fonts.roboto-mono
  ];

  targets.genericLinux.enable = true;
  xdg.enable = true;
  xdg.mime.enable = true;
}
