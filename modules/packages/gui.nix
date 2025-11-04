{ config, pkgs, ... }:

{
  # GUI applications (cross-platform)
  home.packages = with pkgs; [
    firefox
    google-chrome
    keepassxc
  ];
}
