{ config, pkgs, username, system, ... }:

{
  # Enable nix-daemon
  services.nix-daemon.enable = true;

  # Nix settings
  nix.settings = {
    experimental-features = "nix-command flakes";
    trusted-users = [ "@admin" ];
  };

  # System-wide packages
  # environment.systemPackages = with pkgs; [ vim git ];

  # macOS system preferences
  # system.defaults = {
  #   dock = {
  #     autohide = true;
  #     show-recents = false;
  #     tilesize = 48;
  #     mru-spaces = false;
  #   };
  #
  #   finder = {
  #     AppleShowAllExtensions = true;
  #     FXEnableExtensionChangeWarning = false;
  #     ShowPathbar = true;
  #     ShowStatusBar = true;
  #   };
  #
  #   NSGlobalDomain = {
  #     AppleShowAllExtensions = true;
  #     InitialKeyRepeat = 15;
  #     KeyRepeat = 2;
  #     "com.apple.swipescrolldirection" = false; # Disable natural scrolling
  #   };
  #
  #   trackpad = {
  #     Clicking = true; # Enable tap to click
  #   };
  # };

  # Enable Touch ID for sudo
  # security.pam.enableSudoTouchIdAuth = true;

  # Fonts
  # fonts.packages = with pkgs;
  # [ (nerdfonts.override { fonts = [ "FiraCode" "JetBrainsMono" ]; }) ];

  # System state version
  system.stateVersion = 5;
}
