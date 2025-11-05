{ config, pkgs, ... }:

{
  # macOS-only packages
  home.packages = with pkgs; [
    mongodb-compass
    slack
    spotify
    vscode
  ];
}
