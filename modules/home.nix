{ config, pkgs, username, system, nvim-config ? null, ... }:

# don't forget to source $HOME/.nix-profile/etc/profile.d/hm-session-vars.sh in 
# the .zshrc

let
  isLinux = builtins.elem system [ "x86_64-linux" "aarch64-linux" ];
  isDarwin = builtins.elem system [ "x86_64-darwin" "aarch64-darwin" ];
in {
  home.username = username;
  home.homeDirectory =
    if isDarwin then "/Users/${username}" else "/home/${username}";
  home.stateVersion = "25.05";

  imports = [
    ./packages/common.nix
    ./packages/shell
    ./packages/gui.nix
  ]
    ++ (if isLinux then [ ./packages/linux.nix ] else [ ])
    ++ (if isDarwin then [ ./packages/darwin.nix ] else [ ]);

  # Symlink nvim config from flake input (out-of-store, writable if you manage it separately)
  home.file.".config/nvim" = if nvim-config != null then {
    source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.local/share/nvim-config";
  } else {};

  # Clone nvim config from git repo to a separate location (writable)
  home.activation.cloneNvimConfig = if nvim-config != null then
    config.lib.dag.entryAfter ["writeBoundary"] ''
      NVIM_DIR="$HOME/.local/share/nvim-config"
      NVIM_REPO="https://github.com/thomas-maurice/nvim-config.git"

      # If nvim config doesn't exist or isn't a git repo, clone it
      if [ ! -d "$NVIM_DIR/.git" ]; then
        $DRY_RUN_CMD mkdir -p "$HOME/.local/share"
        $DRY_RUN_CMD rm -rf "$NVIM_DIR"
        $DRY_RUN_CMD ${pkgs.git}/bin/git clone "$NVIM_REPO" "$NVIM_DIR"
        echo "Cloned nvim config to $NVIM_DIR"
      else
        # If it exists, just fetch updates (but don't auto-merge)
        echo "Nvim config already exists at $NVIM_DIR, skipping clone"
        echo "Run 'cd ~/.local/share/nvim-config && git pull' to update manually if needed"
      fi
    ''
  else "";

  programs.home-manager.enable = true;
}
