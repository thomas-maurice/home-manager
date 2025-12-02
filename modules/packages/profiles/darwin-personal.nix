{ config, pkgs, ... }:
let
  # Override Python to always use OpenSSL instead of LibreSSL on macOS
  python3 = pkgs.python3.override {
    openssl = pkgs.openssl;
  };

  # Helper function to create Python environments with OpenSSL support
  pythonWithPackages = packages: python3.withPackages packages;
in
{
  home.packages = with pkgs; [
    # cli stuff
    qmk

    # Ansible with hvac support
    (pythonWithPackages (ps: with ps; [
      ansible-core
      hvac
      cryptography
      jinja2
    ]))

    # You can add more Python environments like this:
    # (pythonWithPackages (ps: with ps; [ requests boto3 ]))
    # Or just standalone python3 with OpenSSL:
    # python3

    # GUI stuff
    # bitwarden-desktop
    # discord
    # element-desktop
    # kicad
    # nextcloud-client
    # slack
    # spotify
    virt-manager
    # vscode
  ];
}
