{ config, pkgs, lib, ... }:

{
  # Packages for all platforms
  home.packages = with pkgs; [
    bat
    buf
    curl
    delve
    git
    go
    goimports-reviser
    gosimports
    gofumpt
    golangci-lint
    golines
    gomodifytags
    gopls
    jq
    kubectl
    lazygit
    ripgrep
    tree
    wget

    # for diffs
    nvd
  ];

  home.activation.report-changes = lib.hm.dag.entryAnywhere ''
    if [[ -n "$oldGenPath" ]]; then
      echo ""
      ${pkgs.nvd}/bin/nvd diff "$oldGenPath" "$newGenPath"
    else
      echo "First generation - nothing to compare"
    fi
  '';
}
