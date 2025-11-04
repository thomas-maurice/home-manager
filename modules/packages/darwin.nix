{ config, pkgs, ... }:

{
  # macOS-only packages
  home.packages = with pkgs; [
    ghostty
    spotify
    vscode
  ];

  homebrew.masApps = {
    "wireguard" = 1451685025;
  };
}

