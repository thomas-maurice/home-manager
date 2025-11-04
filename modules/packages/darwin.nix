{ config, pkgs, ... }:

{
  # macOS-only packages
  home.packages = with pkgs; [ caffeine ghostty spotify vscode ];
}

