{ config, pkgs, ... }:

{
  # macOS-specific shared configuration
  imports = [
    ./home-base.nix
    ./packages/darwin.nix
  ];

  home.homeDirectory = "/Users/${config.home.username}";

  programs.zsh.shellAliases = {
    hm-clean = "sudo -H nix-env --delete-generations +1 --profile /nix/var/nix/profiles/system; sudo -H nix-env --delete-generations +1 --profile ~/.local/state/nix/profiles/profile; nix store gc; nix store optimise";
  };
}
