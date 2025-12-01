{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    # cli stuff
    qmk
    ansible

    # GUI stuff
    # bitwarden-desktop
    # discord
    # element-desktop
    # kicad
    # nextcloud-client
    # slack
    # spotify
    # syncthing-macos
    virt-manager
    # vscode
  ];
}
