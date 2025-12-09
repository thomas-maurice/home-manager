{
  config,
  pkgs,
  username,
  nvim-config ? null,
  ...
}:

{
  # Base configuration shared across ALL systems
  home.username = username;
  home.stateVersion = "25.11";

  imports = [
    ./packages/common.nix
    ./packages/shell
    ./packages/neovim
    ./packages/asdf
    ./packages/ssh-gpg-agent
    ./packages/git
  ];

  programs.home-manager.enable = true;
}
