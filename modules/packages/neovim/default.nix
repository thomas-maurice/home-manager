{ config, pkgs, nvim-config ? null, ... }:

{
  # Install neovim
  home.packages = with pkgs; [
    neovim
  ];

  # Symlink nvim config from flake input (out-of-store, writable if you manage it separately)
  home.file.".config/nvim" = if nvim-config != null then {
    source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/.local/share/nvim-config";
  } else {};

  # Clone nvim config from git repo to a separate location (writable)
  home.activation.cloneNvimConfig = if nvim-config != null then
    let
      nvimRev = builtins.substring 0 40 "${nvim-config.rev or "HEAD"}";
    in
    config.lib.dag.entryAfter ["writeBoundary"] ''
      NVIM_DIR="$HOME/.local/share/nvim-config"
      NVIM_REPO="https://github.com/thomas-maurice/nvim-config.git"
      FLAKE_REV="${nvimRev}"

      # If nvim config doesn't exist or isn't a git repo, clone it
      if [ ! -d "$NVIM_DIR/.git" ]; then
        $DRY_RUN_CMD mkdir -p "$HOME/.local/share"
        $DRY_RUN_CMD rm -rf "$NVIM_DIR"
        $DRY_RUN_CMD ${pkgs.git}/bin/git clone "$NVIM_REPO" "$NVIM_DIR"
        echo "Cloned nvim config to $NVIM_DIR"
      fi

      # Sync to flake input version
      cd "$NVIM_DIR"
      CURRENT_REV=$(${pkgs.git}/bin/git rev-parse HEAD)
      if [ "$CURRENT_REV" != "$FLAKE_REV" ]; then
        echo "Syncing nvim config to flake input version: $FLAKE_REV"
        $DRY_RUN_CMD ${pkgs.git}/bin/git fetch origin
        $DRY_RUN_CMD ${pkgs.git}/bin/git checkout "$FLAKE_REV" || echo "Warning: Could not checkout $FLAKE_REV, staying on current revision"
      else
        echo "Nvim config already at flake input version: $FLAKE_REV"
      fi
    ''
  else "";
}
