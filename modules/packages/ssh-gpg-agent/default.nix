{
  config,
  pkgs,
  lib,
  gpgSshKeygrips ? [ ],
  ...
}:

let
  isLinux = pkgs.stdenv.hostPlatform.isLinux;
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;

  # Example keygrip structure (for documentation):
  # gpgSshKeygrips = [
  #   {
  #     keygrip = "A12EA21D952DB75C316811CFBB001B3577D62616";
  #     comment = "Ed25519 key added on: 2024-07-01 14:23:21\nFingerprints:  MD5:70:7c:59:0d:17:ed:da:45:b4:cb:93:28:b1:00:43:d0\n               SHA256:7Pwde1KORiFF8DOW/tahO3rKAL5YCNFv9pYXicRhgac";
  #     flags = "0";  # 0 = no confirmation required
  #   }
  # ];

  # Generate sshcontrol content from keygrips list
  sshcontrolContent =
    if gpgSshKeygrips == [ ] then
      ""
    else
      lib.concatMapStringsSep "\n" (entry: ''
        # ${entry.comment}
        ${entry.keygrip}${if entry.flags != "" then " ${entry.flags}" else ""}
      '') gpgSshKeygrips;
in
{
  # Install platform-specific pinentry programs and smartcard support
  home.packages =
    with pkgs;
    [
      gnupg
    ]
    ++ lib.optionals isLinux [
      pinentry-gnome3
      pcsclite # PC/SC smartcard library (Linux only)
      pcsc-tools # Tools for testing smartcard readers (Linux only)
    ];

  # GPG configuration
  programs.gpg = {
    enable = true;

    scdaemonSettings = {
      disable-ccid = true;
      card-timeout = "1";
    };

    settings = {
      # Cipher preferences
      personal-cipher-preferences = "AES256 AES192 AES";
      personal-digest-preferences = "SHA512 SHA384 SHA256";
      personal-compress-preferences = "ZLIB BZIP2 ZIP Uncompressed";

      # Default preferences for new keys
      default-preference-list = "SHA512 SHA384 SHA256 AES256 AES192 AES ZLIB BZIP2 ZIP Uncompressed";

      # Digest algorithms
      cert-digest-algo = "SHA512";
      s2k-digest-algo = "SHA512";
      s2k-cipher-algo = "AES256";

      # Display options
      charset = "utf-8";
      fixed-list-mode = true;
      no-comments = true;
      no-emit-version = true;
      no-greeting = true;
      keyid-format = "0xlong";
      with-fingerprint = true;

      # List and verify options
      list-options = "show-uid-validity show-unusable-subkeys";
      verify-options = "show-uid-validity";

      # Security options
      require-cross-certification = true;
      no-symkey-cache = true;
      use-agent = true;
      armor = true;
      throw-keyids = true;

      # Keyserver
      keyserver = "hkps://keyserver.ubuntu.com:443";
    };
  };

  # GPG Agent configuration
  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    enableExtraSocket = true;

    # default-cache-ttl is the idle timer (resets on each use); max-cache-ttl is
    # an absolute ceiling from first unlock that cannot be reset. Keeping them
    # equal at 24h means one passphrase entry per day.
    defaultCacheTtl = 86400;
    defaultCacheTtlSsh = 86400;
    maxCacheTtl = 86400;
    maxCacheTtlSsh = 86400;

    # Platform-specific pinentry program.
    #
    # On Darwin, deliberately NOT nixpkgs' pinentry_mac. pinentry-mac stores
    # passphrases in the login keychain, and the ACL it writes binds the entry
    # to the calling binary's cdhash (it is only ad-hoc signed, no Team ID).
    # The nixpkgs build embeds its own store path, so every rebuild produces a
    # new cdhash even for an identical upstream version: the saved passphrase
    # becomes unreadable and "Save in Keychain" silently stops working. The ACL
    # on the SSH keygrip item had accumulated five dead store paths, all
    # status -2147415734 ("code object not found").
    #
    # Homebrew's pinentry-mac is ad-hoc signed too, but its content only changes
    # on an actual pinentry-mac release rather than on every flake bump, so the
    # keychain entry survives. Its bin/pinentry-mac is a wrapper that execs the
    # .app bundle, and that bundle is the identity macOS records in the ACL.
    #
    # Setting the package to null suppresses home-manager's own
    # pinentry-program line so extraConfig can supply the absolute path.
    # Requires the "pinentry-mac" brew declared in darwin/configuration.nix.
    pinentry.package = if isLinux then pkgs.pinentry-gnome3 else null;
    extraConfig = lib.optionalString isDarwin ''
      pinentry-program /opt/homebrew/bin/pinentry-mac
    '';
  };

  # On Darwin, home-manager's launchd agent binds the agent sockets under
  # /private/var/run/org.nix-community.home.gpg-agent/, but the gpgconf binary
  # reports $GNUPGHOME (~/.gnupg) as the socketdir and there is no config option
  # to relocate it. The two never reconcile: `gpg-agent --supervised` never
  # creates ~/.gnupg/S.gpg-agent*, the first client auto-spawns a plain
  # --use-standard-socket daemon there instead, and the supervised agent then
  # exits 2 ("agent already running") on every launch. With
  # KeepAlive.SuccessfulExit = false that respawns forever.
  # Let GnuPG auto-spawn the standard-socket agent, which is the normal macOS
  # mode and restarts on demand anyway. mkForce is required because HM assigns
  # enable = true plainly, which would otherwise be a conflict rather than an
  # override.
  launchd.agents.gpg-agent.enable = lib.mkIf isDarwin (lib.mkForce false);

  # SSH configuration to use GPG agent
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false; # Disable auto-defaults, set explicitly below

    settings = {
      "github.com" = {
        hostname = "github.com";
        user = "git";
        identityFile = "~/.ssh/id_ed25519";
        identitiesOnly = true;
      };

      "*" = {
        forwardAgent = true;
        forwardX11 = false;
        serverAliveInterval = 60;
        serverAliveCountMax = 30;
        identityFile = "~/.ssh/gpg.pub";
        user = "adm";
        addKeysToAgent = "yes";
        # Explicit defaults (previously auto-added by home-manager)
        compression = false;
        hashKnownHosts = false;
        userKnownHostsFile = "~/.ssh/known_hosts";
        controlMaster = "no";
        controlPath = "~/.ssh/master-%r@%n:%p";
        controlPersist = "no";
      };

      "git.maurice.fr" = {
        hostname = "git.maurice.fr";
        port = 2222;
        user = "gitea";
        identityFile = "~/.ssh/id_ed25519";
        addKeysToAgent = "yes";
      };

      "gitea.plil.fr" = {
        hostname = "2001:660:4401:6011:216:3eff:feb8:3f74";
        port = 22;
        user = "tmaurice";
        identityFile = "~/.ssh/id_ed25519";
        addKeysToAgent = "yes";
      };
    };
  };

  # Create sshcontrol file with your GPG keys (if any provided)
  home.file.".gnupg/sshcontrol_link" = lib.mkIf (gpgSshKeygrips != [ ]) {
    text = sshcontrolContent;
    onChange = ''
      cat ~/.gnupg/sshcontrol_link > ~/.gnupg/sshcontrol
      rm ~/.gnupg/sshcontrol_link
      chmod 600 ~/.gnupg/sshcontrol

      # Restart gpg-agent to pick up new sshcontrol
      ${pkgs.gnupg}/bin/gpgconf --kill gpg-agent || true
      ${pkgs.gnupg}/bin/gpgconf --launch gpg-agent || true
    '';
    force = true;
  };
}
