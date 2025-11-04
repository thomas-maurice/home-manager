{ config, pkgs, ... }:

{
  # macOS-only packages
  home.packages = with pkgs; [
    jellyfin-media-player
    mongodb-compass
    slack
    spotify
    vscode
  ];
}

