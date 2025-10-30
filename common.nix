{ config, pkgs, ... }:

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
  ];
}
