{
  config,
  pkgs,
  lib,
  system,
  ...
}:

let
  isLinux = builtins.elem system [
    "x86_64-linux"
    "aarch64-linux"
  ];
  isDarwin = builtins.elem system [
    "x86_64-darwin"
    "aarch64-darwin"
  ];
in
{
  home.packages = with pkgs; [
    atuin
    tmux
    zellij
    zsh-powerlevel10k
  ];

  programs.atuin = {
    enable = true;
    enableZshIntegration = true;
    flags = [ "--disable-up-arrow" ];
  };

  programs.direnv = {
    enable = true;
    enableZshIntegration = true; 
    nix-direnv.enable = true;
  };

  programs.zsh = {
    enable = true;
    enableCompletion = true;

    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };

    shellAliases = {
      # Common aliases for all systems
      ls = "ls --color=auto";
      dir = "dir --color=auto";
      vdir = "vdir --color=auto";
      grep = "grep --color=auto";
      fgrep = "fgrep --color=auto";
      egrep = "egrep --color=auto";
      ll = "ls -lh";
      la = "ls -a";
      l = "ls -CF";
      k = "kubectl";
      vim = "nvim";
      hmu = "nix flake update --flake ~/.config/home-manager";
      # hm and hm-clean are profile-specific, defined in profiles/*.nix
    };

    oh-my-zsh = {
      enable = true;
      theme = "robbyrussell";
      plugins = [
        "asdf"
        # "git"
        "direnv"
        # "docker"
        # "kind"
        # "kubectl"
        # "kubectx"
        # "terraform"
      ];
    };

    plugins = [
      {
        name = "powerlevel10k";
        src = pkgs.zsh-powerlevel10k;
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }
    ];

    initContent = lib.mkMerge [
      (lib.mkBefore ''
        # Source nix daemon profile (MUST be first for PATH)
        if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
          . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
        fi

        # Source home-manager session variables
        if [ -e "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh" ]; then
          . "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
        fi
      '')
      ''

        # Enable Powerlevel10k instant prompt
        if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
          source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
        fi

        export ASDF_DATA_DIR="''${ASDF_DATA_DIR:-$HOME/.asdf}"
        export PATH="''${ASDF_DATA_DIR:-$HOME/.asdf}/shims:$PATH"

        ${lib.optionalString isDarwin ''
          # Add nix-darwin system binaries to PATH
          export PATH="/run/current-system/sw/bin:$PATH"

          # Add Homebrew to PATH (after Nix binaries)
          if [ -x /opt/homebrew/bin/brew ]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
          fi

          # set the python path so it's the darwin one
          export PATH="$(brew --prefix python)/libexec/bin:$PATH"

        ''}

        # Source p10k configuration
        [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

        # Source local zshrc if it exists
        [[ ! -f ~/.zshrc.local ]] || source ~/.zshrc.local

        if [ -d $HOME/.krew ]; then 
          export PATH="''${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
        fi;

        # if which direnv 2>&1 > /dev/null; then
        #   eval "$(direnv hook zsh)"
        # fi;

        # Set SSH_AUTH_SOCK to use GPG agent for SSH
        ${lib.optionalString isLinux ''
          export SSH_AUTH_SOCK="''${XDG_RUNTIME_DIR}/gnupg/S.gpg-agent.ssh"
        ''}
        ${lib.optionalString isDarwin ''
          export SSH_AUTH_SOCK="$HOME/.gnupg/S.gpg-agent.ssh"
        ''}
      ''
    ];
  };

  # Manage the .p10k.zsh configuration file (vendored as out-of-store symlink)
  home.file.".p10k.zsh".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/home-manager/modules/packages/shell/p10k.zsh";

  # Tmux configuration (vendored as out-of-store symlink)
  home.file.".tmux.conf".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/home-manager/modules/packages/shell/tmux.conf";

  # Ghostty terminal configuration (vendored as out-of-store symlink)
  home.file.".config/ghostty/config".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/home-manager/modules/packages/shell/ghostty.config";

  # Zellij configuration (vendored as out-of-store symlink)
  home.file.".config/zellij/config.kdl".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.config/home-manager/modules/packages/shell/zellij-config.kdl";
}
