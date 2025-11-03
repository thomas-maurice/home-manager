{ config, pkgs, ... }:

{
  # Linux-only packages
  home.packages = with pkgs; [
    curl
  ];

  fonts.packages = [
    nerd-fonts.jetbrains-mono
    nerd-fonts.roboto-mono
  ]

  targets.genericLinux.enable = true;
  xdg.enable = true;
  xdg.mime.enable = true;
}
