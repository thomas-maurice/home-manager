{
  config,
  pkgs,
  lib,
  ...
}:

{
  # Packages for all platforms
  home.packages = with pkgs; [
    # general console environment
    age
    atuin
    bat
    btop
    chezmoi
    curl
    # provided through nix direnv
    # direnv
    fastfetch
    fzf
    # git
    gawk
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
    wireguard-tools
    yq-go
    zellij

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

    ## orm stuff
    goose
    atlas

    ## protobuf
    buf
    grpcurl
    protobuf
    protobufc
    protoc-gen-connect-go
    protoc-gen-go
    protoc-gen-go-grpc
    protoc-gen-connect-go
    protoc-go-inject-tag

    ## cloud stuff
    awscli
    azure-cli
    consul
    google-cloud-sdk
    k9s
    kind
    kubectl
    kubectx
    kubelogin-oidc
    kubernetes-helm
    kustomize
    krew
    minio-client
    sops
    temporal-cli
    vault-bin

    # database stuff
    postgresql
    natscli
    nsc

    # nix specific things
    nil
    nixd
    nixfmt
    nvd

    # the equivalent of 'build-essentials' on ubuntu
    # or base-devel on arch, to be able to have at least
    # a basic c compiler available
    autoconf
    automake
    bison
    flex
    fontforge
    gnumake
    gcc
    libiconv
    libtool
    makeWrapper
    pkg-config

    # misc
    irssi
  ];

  home.activation.report-changes = lib.hm.dag.entryAnywhere ''
    if [ -n "''${oldGenPath:-}" ]; then
      echo ""
      ${pkgs.nvd}/bin/nvd diff "$oldGenPath" "$newGenPath"
    else
      echo "First generation - nothing to compare"
    fi
  '';

  fonts.fontconfig.enable = true;
}
