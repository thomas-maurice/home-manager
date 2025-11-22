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
    zsh-powerlevel10k
  ];

  programs.zsh = {
    enable = true;
    enableCompletion = true;

    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };

    shellAliases = {
      ls = "ls --color=auto";
      dir = "dir --color=auto";
      vdir = "vdir --color=auto";
      grep = "grep --color=auto";
      fgrep = "fgrep --color=auto";
      egrep = "egrep --color=auto";
      ll = "ls -lh";
      la = "ls -a";
      l = "ls -CF";
      vim = "nvim";
      hmu = "nix flake update --flake ~/.config/home-manager";
    }
    // (
      if isLinux then
        {
          hm = "home-manager switch --flake ~/.config/home-manager#thomas@linux; exec zsh";
          hm-clean = "home-manager expire-generations '-0 days'; nix-env --delete-generations old; nix store gc; nix store optimise";
        }
      else
        {
          hm = "sudo -H nix run nix-darwin/master#darwin-rebuild -- switch --flake ~/.config/home-manager#thomas@mac; exec zsh";
          drs = "sudo -H nix run nix-darwin/master#darwin-rebuild -- switch --flake ~/.config/home-manager#thomas@mac; exec zsh";
          hm-clean = "sudo nix-env --delete-generations +1 --profile /nix/var/nix/profiles/system; nix store gc; nix store optimise";
        }
    );

    oh-my-zsh = {
      enable = true;
      theme = "robbyrussell";
      plugins = [
        "git"
        "docker"
        "kubectl"
        "terraform"
      ];
    };

    plugins = [
      {
        name = "powerlevel10k";
        src = pkgs.zsh-powerlevel10k;
        file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
      }
    ];

    initContent = ''
      if [ -f ${pkgs.asdf-vm}/share/asdf-vm/asdf.sh ]; then
        . ${pkgs.asdf-vm}/share/asdf-vm/asdf.sh
        #fpath=(${pkgs.asdf-vm}/share/zsh/site-functions $fpath)
      fi

      # Source nix daemon profile (MUST be first for PATH)
      if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
        . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
      fi

      # Source home-manager session variables
      if [ -e "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh" ]; then
        . "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
      fi

      ${lib.optionalString isDarwin ''
        # Add nix-darwin system binaries to PATH
        export PATH="/run/current-system/sw/bin:$PATH"

        # Add Homebrew to PATH (after Nix binaries)
        if [ -x /opt/homebrew/bin/brew ]; then
          eval "$(/opt/homebrew/bin/brew shellenv)"
        fi
      ''}

      # Enable Powerlevel10k instant prompt
      if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
        source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
      fi

      # Source p10k configuration
      [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

      # Source local zshrc if it exists
      [[ ! -f ~/.zshrc.local ]] || source ~/.zshrc.local

      if [ -d $HOME/.krew ]; then 
        export PATH="''${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
      fi;
    '';
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
}
