{ config, pkgs, username, system, ... }:

{
  # Nix settings
  nix.settings = {
    experimental-features = "nix-command flakes";
    trusted-users = [ "@admin" ];
  };

  nixpkgs.config.allowUnsupportedSystem = true;
  nixpkgs.config.allowUnfree = true;

  # System-wide packages
  environment.systemPackages = with pkgs; [ home-manager git ];

  # Create aliases for GUI apps in /Applications/Nix Apps
  # This makes them discoverable by Spotlight
  system.activationScripts.applications.text = let
    env = pkgs.buildEnv {
      name = "system-applications";
      paths = config.environment.systemPackages;
      pathsToLink = "/Applications";
    };
  in pkgs.lib.mkForce ''
    # Set up applications
    echo "setting up /Applications/Nix Apps..." >&2
    rm -rf /Applications/Nix\ Apps
    mkdir -p /Applications/Nix\ Apps
    find ${env}/Applications -maxdepth 1 -type l -exec readlink '{}' + | 
    while read -r src; do
      app_name=$(basename "$src")
      echo "copying $src" >&2
      ${pkgs.mkalias}/bin/mkalias "$src" "/Applications/Nix Apps/$app_name"
    done
  '';

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

  # leave there *rc intact
  programs.zsh.enable = false;
  programs.bash.enable = false;
}
