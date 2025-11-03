{ config, pkgs, ... }:

{
  # Linux-only packages
  home.packages = with pkgs; [ ];

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.roboto-mono
  ]
}

