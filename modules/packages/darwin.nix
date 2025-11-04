{ config, pkgs, ... }:

{
  # macOS-only packages
  home.packages = with pkgs; [
    ghostty
    spotify
    vscode
  ];
}

