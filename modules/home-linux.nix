{ config, pkgs, ... }:

{
  # Linux-specific shared configuration
  imports = [
    ./home-base.nix
    ./packages/linux.nix
    ./packages/asdf
  ];

  home.homeDirectory = "/home/${config.home.username}";
}
