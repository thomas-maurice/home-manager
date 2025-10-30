{ config, pkgs, ... }:

{
  # Packages for all platforms
  home.packages = with pkgs; [ curl kubectl wget htop btop bat jq ];
}
