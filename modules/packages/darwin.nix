{ config, pkgs, ... }:

{
  # Linux-only packages
  home.packages = with pkgs; [ ];

  fonts.packages = [
    nerd-fonts.jetbrains-mono
    nerd-fonts.roboto-mono
  ]
}

