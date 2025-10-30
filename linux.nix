{ config, pkgs, ... }:

{
  # Linux-only packages
  home.packages = with pkgs; [ curl ];
}
