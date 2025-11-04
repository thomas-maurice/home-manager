{ config, pkgs, username, system, ... }:

{
  # Nix settings
  nix.settings = {
    experimental-features = "nix-command flakes";
    trusted-users = [ "@admin" ];
  };

  nixpkgs.config.allowUnsupportedSystem = true;
  nixpkgs.config.allowUnfree = true;

  system.primaryUser = "thomas";

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
  system.defaults = {
    NSGlobalDomain = {
      AppleInterfaceStyle = "Dark"; # Enable dark mode
      "com.apple.swipescrolldirection" = false; # Disable natural scrolling (reverse scroll direction)
    };

    trackpad = {
      Clicking = true; # Enable tap to click
    };
  };

  # Enable Touch ID for sudo
  # security.pam.enableSudoTouchIdAuth = true;

  # Fonts
  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.roboto-mono
  ];

  # Homebrew configuration
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = true;
      upgrade = true;
    };

    brews = [
      # Add your brew packages here
    ];

    casks = [
      "caffeine"  # Keep Mac awake
    ];

    masApps = {
      # App Store apps - find IDs with: nix run nixpkgs#mas -- search "app name"
      "wireguard" = 1451685025;
    };
  };

  # System state version
  system.stateVersion = 5;

  # leave there *rc intact
  programs.zsh.enable = false;
  programs.bash.enable = false;
}
