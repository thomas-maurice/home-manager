{ config, pkgs, lib, ... }:

{
  # Packages for all platforms
  home.packages = with pkgs; [
    # general console environment
    age
    asdf-vm
    atuin
    bat
    btop
    chezmoi
    curl
    direnv
    fastfetch
    fzf
    git
    gnupg
    htop
    jq
    lazygit
    powerline
    pwgen
    qrencode
    rclone
    rsync
    ripgrep
    tmux
    tree
    wget
    yq-go

    # development
    # cargo to compile rust stuff
    cargo
    rustc
    # qmk
    # qmk
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
    protoc-gen-connect-go
    protoc-gen-go
    protoc-gen-go-grpc
    protoc-go-inject-tag

    ## cloud stuff
    awscli
    azure-cli
    consul
    google-cloud-sdk
    k9s
    kind
    kubectl
    kubelogin-oidc
    kubernetes-helm
    kustomize
    minio-client
    sops
    temporal-cli
    terraform
    vault

    # database stuff
    postgresql

    # nix specific things
    nil
    nixd
    nixfmt
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

  fonts.fontconfig.enable = true;
}
