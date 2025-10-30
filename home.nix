{ config, pkgs, username, system, ... }:

# don't forget to source $HOME/.nix-profile/etc/profile.d/hm-session-vars.sh in 
# the .zshrc

let
  isLinux = builtins.elem system [ "x86_64-linux" "aarch64-linux" ];
  isDarwin = builtins.elem system [ "x86_64-darwin" "aarch64-darwin" ];
in {
  home.username = username;
  home.homeDirectory =
    if pkgs.stdenv.isDarwin then "/Users/${username}" else "/home/${username}";
  home.stateVersion = "25.05";

  imports = [ ./common.nix ] ++ (if isLinux then [ ./linux.nix ] else [ ])
    ++ (if isDarwin then [ ./darwin.nix ] else [ ]);

  programs.home-manager.enable = true;
}
