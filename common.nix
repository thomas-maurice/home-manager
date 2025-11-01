{ config, pkgs, lib, ... }:

{
  # Packages for all platforms
  home.packages = with pkgs; [
    # general console environment
    atuin
    bat
    btop
    curl
    fzf
    git
    htop
    jq
    lazygit
    ripgrep
    tree
    wget
    yq-go

    # development
    ## editors
    neovim
    vim

    ## neovim
    luarocks
    nodejs_24 # needed for npm

    ## go 
    delve
    go
    goimports-reviser
    gosimports
    gofumpt
    golangci-lint
    golines
    gomodifytags
    gopls

    ## protobuf
    buf
    protobuf
    protobufc
    protoc-gen-go
    protoc-gen-go-grpc

    ## cloud stuff
    consul
    helm
    k9s
    kind
    kubectl
    kustomize
    minio-client
    sops
    temporal-cli
    terraform
    vault

    # nix specific things
    nixd
    nil
    nvd

    # fonts
    nerd-fonts.jetbrains-mono
    nerd-fonts.roboto-mono
  ];

  home.activation.report-changes = lib.hm.dag.entryAnywhere ''
    if [[ -n "$oldGenPath" ]]; then
      echo ""
      ${pkgs.nvd}/bin/nvd diff "$oldGenPath" "$newGenPath"
    else
      echo "First generation - nothing to compare"
    fi
  '';

  fonts.fontconfig.enable = true;
}
