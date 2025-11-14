{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    darwin = {
      url = "github:nix-darwin/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mac-app-util = {
      url = "github:hraban/mac-app-util";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.cl-nix-lite.url = "github:r4v3n6101/cl-nix-lite/url-fix";
    };
    nix-homebrew = {
      url = "github:zhaofengli/nix-homebrew";
    };
    homebrew-bundle = {
      url = "github:homebrew/homebrew-bundle";
      flake = false;
    };
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    nvim-config = {
      url = "github:thomas-maurice/nvim-config";
      flake = false;
    };
  };

  outputs = { nixpkgs, home-manager, darwin, mac-app-util, nix-homebrew, homebrew-bundle, homebrew-core, homebrew-cask, nvim-config, ... }:
  let
    user = "thomas";
  in
  {
    # Linux home-manager configuration
    homeConfigurations = {
      "thomas@linux" = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          system = "x86_64-linux";
          config.allowUnfree = true;
        };
        modules = [ ./modules/home.nix ];
        extraSpecialArgs = {
          username = "thomas";
          system = "x86_64-linux";
          inherit nvim-config;
          # Override asdf tools for Linux (optional)
          # asdfTools = {
          #   terraform = "1.14.0";
          #   vault = "1.21.0";
          #   python = "3.12.0";
          # };
        };
      };
    };

    # macOS nix-darwin configuration (separate from homeConfigurations!)
    darwinConfigurations."thomas@mac" = darwin.lib.darwinSystem {
      system = "aarch64-darwin";
      pkgs = import nixpkgs {
        system = "aarch64-darwin";
        config = {
          allowUnfree = true;
        };
      };
      modules = [
        ./darwin/configuration.nix

        nix-homebrew.darwinModules.nix-homebrew
        {
          nix-homebrew = {
            inherit user;
            enable = true;
            enableRosetta = true;
            mutableTaps = true;
          };
        }

        home-manager.darwinModules.home-manager
        {
          # needed otherwise nix-darwin will shit itself
          users.users.thomas.home = "/Users/thomas";

          home-manager.useGlobalPkgs = true;
          home-manager.users.thomas = import ./modules/home.nix;
          home-manager.extraSpecialArgs = {
            username = "thomas";
            system = "aarch64-darwin";
            inherit nvim-config;
            # Override asdf tools for macOS (optional)
            # asdfTools = {
            #   terraform = "1.14.0";
            #   vault = "1.21.0";
            # };
          };
          home-manager.sharedModules = [
            mac-app-util.homeManagerModules.default
          ];
        }
      ];
    };
  };
}
