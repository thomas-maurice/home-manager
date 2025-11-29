{ config, pkgs, ... }:
{
  home.packages =
    with pkgs;
    [
      # cli stuff
      qmk

      # GUI stuff
      bitwarden-desktop
      discord
      element-desktop
      kicad
      nextcloud-client
      slack
      spotify
      virt-manager
      vscode
    ];
}