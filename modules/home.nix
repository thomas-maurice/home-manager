{ config, pkgs, username, system, nvim-config ? null, ... }:

let
  isLinux = builtins.elem system [ "x86_64-linux" "aarch64-linux" ];
  isDarwin = builtins.elem system [ "x86_64-darwin" "aarch64-darwin" ];
in {
  home.username = username;
  home.homeDirectory =
    if isDarwin then "/Users/${username}" else "/home/${username}";
  home.stateVersion = "25.11";

  imports = [
    ./packages/common.nix
    ./packages/shell
    ./packages/neovim
    ./packages/asdf
  ]
    ++ (if isLinux then [ ./packages/linux.nix ] else [ ])
    ++ (if isDarwin then [ ./packages/darwin.nix ] else [ ]);

  programs.home-manager.enable = true;
}
