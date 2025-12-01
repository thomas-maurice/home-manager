{ config, pkgs, ... }:
let
  # Override Python to use OpenSSL instead of LibreSSL
  python3WithOpenSSL = pkgs.python3.override {
    openssl = pkgs.openssl;
  };
in
{
  home.packages = with pkgs; [
    # cli stuff
    qmk
    (python3WithOpenSSL.withPackages (ps: with ps; [
      ansible-core
      hvac
      cryptography
      jinja2
    ]))

    # GUI stuff
    # bitwarden-desktop
    # discord
    # element-desktop
    # kicad
    # nextcloud-client
    # slack
    # spotify
    syncthing-macos
    virt-manager
    # vscode
  ];
}
