{ config, pkgs, ... }:

{
  # macOS-only packages
  home.packages = with pkgs; [
    openssh

    mongodb-compass
    slack
    spotify
    vscode
  ];
}
