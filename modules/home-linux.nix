{ config, pkgs, ... }:

{
  # Linux-specific shared configuration
  imports = [
    ./home-base.nix
    ./packages/linux.nix
  ];

  home.homeDirectory = "/home/${config.home.username}";
}
