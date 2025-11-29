{ config, pkgs, ... }:

{
  # macOS-specific shared configuration
  imports = [
    ./home-base.nix
    ./packages/darwin.nix
  ];

  home.homeDirectory = "/Users/${config.home.username}";
}
