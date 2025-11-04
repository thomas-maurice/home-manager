{ config, pkgs, ... }:

{
  # macOS-only packages
  home.packages = with pkgs; [ caffeine ghostty spotify vscode ];

  homebrew.masApps = { "wireguard" = 1451685025; };
}

