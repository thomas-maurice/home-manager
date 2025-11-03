{ config, pkgs, lib, ... }:

{
  # Linux-only packages
  home.packages = with pkgs; [
    curl
    # fonts
    nerd-fonts.jetbrains-mono
    nerd-fonts.roboto-mono
  ];

  targets.genericLinux.enable = true;
  xdg.enable = true;
  xdg.mime.enable = true;

  # Rebuild font cache when fonts change
  home.activation.rebuildFontCache = lib.hm.dag.entryAfter ["writeBoundary"] ''
    if command -v fc-cache >/dev/null 2>&1; then
      run fc-cache -fv
    fi
  '';
}
