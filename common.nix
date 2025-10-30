{ config, pkgs, ... }:

{
  # Packages for all platforms
  home.packages = with pkgs; [
    bat
    curl
    git
    go
    goimports-reviser
    gosimports
    gofumpt
    golangci-lint
    jq
    kubectl
    lazygit
    ripgrep
    tree
    wget
  ];
}
