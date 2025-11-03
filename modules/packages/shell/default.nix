{ config, pkgs, lib, system, ... }:

let
  isLinux = builtins.elem system [ "x86_64-linux" "aarch64-linux" ];
  isDarwin = builtins.elem system [ "x86_64-darwin" "aarch64-darwin" ];
in
{
  home.packages = with pkgs; [
    zsh-powerlevel10k
  ];

  programs.zsh = {
    enable = true;
    enableCompletion = true;

    sessionVariables = {
      EDITOR = "vim";
      VISUAL = "vim";
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
    } // (if isLinux then {
      hm = "home-manager switch --flake ~/.config/home-manager#thomas@linux";
      hm-clean = "home-manager expire-generations '-0 days'; nix-env --delete-generations old; nix store gc; nix store optimise";
    } else {});

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
      # Source nix daemon profile
      if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
        . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
      fi

      # Source home-manager session variables
      if [ -e "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh" ]; then
        . "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
      fi

      # Enable Powerlevel10k instant prompt
      if [[ -r "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh" ]]; then
        source "''${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-''${(%):-%n}.zsh"
      fi

      # Source p10k configuration
      [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

      # Source local zshrc if it exists
      [[ ! -f ~/.zshrc.local ]] || source ~/.zshrc.local
    '';
  };

  # Manage the .p10k.zsh configuration file (vendored)
  home.file.".p10k.zsh".source = ./p10k.zsh;

  # Ghostty terminal configuration
  programs.ghostty.settings = {
    theme = "Adwaita Dark";
    cursor-style-blink = true;
    cursor-style = "block";
    shell-integration-features = "no-cursor";

    keybind = [
      "alt+right=goto_split:right"
      "alt+left=goto_split:left"
      "alt+up=goto_split:top"
      "alt+down=goto_split:bottom"
      "ctrl+shift+o=new_split:down"
      "ctrl+shift+e=new_split:right"
    ];
  };
}
