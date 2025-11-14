{ config, pkgs, ... }:

let
  # Import GUI packages list
  guiPackages = import ./gui.nix { inherit pkgs; };
in
{
  # macOS-only packages
  home.packages = with pkgs; [
    mongodb-compass
    slack
    spotify
    vscode
  ] ++ guiPackages;
}
