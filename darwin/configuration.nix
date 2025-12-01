{
  config,
  pkgs,
  username,
  system,
  ...
}:

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
  environment.systemPackages = with pkgs; [
    btop
    curl
    home-manager
    htop
    # git
    vim
    wget
  ];

  # macOS system preferences
  system.defaults = {
    NSGlobalDomain = {
      AppleInterfaceStyle = "Dark"; # Enable dark mode
      "com.apple.swipescrolldirection" = false; # Disable natural scrolling (reverse scroll direction)
    };

    trackpad = {
      Clicking = false; # Disable tap to click
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
      autoUpdate = false;
      upgrade = true;
    };

    brews = [
      # Add your brew packages here
    ];

    casks = [
      "caffeine" # Keep Mac awake
      "flameshot"
    ];

    masApps = {
      # App Store apps - find IDs with: nix run nixpkgs#mas -- search "app name"
      "wireguard" = 1451685025;
      "UTM Virtual Machines" = 1538878817;
    };
  };

  # System state version
  system.stateVersion = 5;

  # leave there *rc intact
  programs.zsh.enable = false;
  programs.bash.enable = false;
}
