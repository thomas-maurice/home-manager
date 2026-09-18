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

  environment.etc = {
    "resolver/starnet.maurice.fr".text = ''
      nameserver 10.99.6.99
      nameserver fc69:dead:cafe::600:99
    '';
    "resolver/lil.maurice.fr".text = ''
      nameserver 10.99.6.99
      nameserver fc69:dead:cafe::600:99
    '';
  };

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

  # Enable Touch ID for sudo. (The old security.pam.enableSudoTouchIdAuth was
  # renamed to this.) reattach pulls in pam-reattach, without which pam_tid
  # silently fails inside tmux panes.
  security.pam.services.sudo_local = {
    touchIdAuth = true;
    reattach = true;
  };

  # 5 minutes is already sudo's own default, so this line changes nothing today.
  # It is here to make the knob discoverable — the value is in minutes.
  #
  # Note that the more common annoyance is tty_tickets (on by default): every
  # terminal tab and tmux pane keeps its own ticket, so a fresh pane re-prompts
  # regardless of this timeout. Add `Defaults !tty_tickets` below to share one
  # ticket across the whole login session instead.
  #
  # This option is types.nullOr types.lines and nix-darwin's terminfo module
  # already defines it, so the definitions concatenate rather than conflict.
  security.sudo.extraConfig = ''
    Defaults timestamp_timeout=5
  '';

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
      "ca-certificates"
      "dfu-util"
      "gh"
      "hidapi"
      "libusb"
      "openssl"
      # Used as gpg-agent's pinentry-program; see modules/packages/ssh-gpg-agent.
      "pinentry-mac"
      "pkgconf"
      "python"
      "stm32flash"
      "stlink"
      "sqlite"
      "anomalyco/tap/opencode"
      "oven-sh/bun/bun"
      "uv"
    ];

    casks = [
      "caffeine" # Keep Mac awake
      "claude-code"
      "claude"
      "grandperspective"
      "macos-fuse-t/homebrew-cask/fuse-t"
      "ollama-app"
    ];

    masApps = {
      # App Store apps - find IDs with: nix run nixpkgs#mas -- search "app name"
      "wireguard" = 1451685025;
      "UTM Virtual Machines" = 1538878817;
      "Hidden bar" = 1452453066;
      "Amphetamine" = 937984704;
    };
  };

  # System state version
  system.stateVersion = 5;

  # leave there *rc intact
  programs.zsh.enable = false;
  programs.bash.enable = false;
}
