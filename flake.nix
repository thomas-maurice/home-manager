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
  };

  outputs = { nixpkgs, home-manager, darwin, nix-homebrew, homebrew-bundle, homebrew-core, homebrew-cask, ... }:
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
            taps = {
              "homebrew/homebrew-core" = homebrew-core;
              "homebrew/homebrew-cask" = homebrew-cask;
              "homebrew/homebrew-bundle" = homebrew-bundle;
            };
            mutableTaps = true;
            autoMigrate = true;
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
          };
        }
      ];
    };
  };
}
