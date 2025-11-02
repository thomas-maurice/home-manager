{ config, pkgs, ... }:

{
  # Linux-only packages
  home.packages = with pkgs; [ curl ];

  targets.genericLinux.enable = true;
  xdg.enable = true;
  xdg.mime.enable = true;
}
