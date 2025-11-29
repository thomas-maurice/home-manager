{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      # url = "git+file:///home/thomas/git/home-manager";
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
    nvim-config = {
      url = "github:thomas-maurice/nvim-config";
      flake = false;
    };
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      darwin,
      nix-homebrew,
      homebrew-bundle,
      homebrew-core,
      homebrew-cask,
      nvim-config,
      ...
    }:
    let
      user = "thomas";
    in
    {
      # Linux home-manager configurations
      homeConfigurations = {
        # Linux laptop configuration
        "thomas@linux-laptop" = home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            system = "x86_64-linux";
            config.allowUnfree = true;
          };
          modules = [ ./modules/profiles/linux-laptop.nix ];
          extraSpecialArgs = {
            username = "thomas";
            system = "x86_64-linux";
            inherit nvim-config;

            # GPG SSH keygrips for laptop
            gpgSshKeygrips = [
              {
                keygrip = "A12EA21D952DB75C316811CFBB001B3577D62616";
                comment = "GPG SSH key for Linux laptop";
                flags = "0";
              }
            ];

            # Git signing key
            signingKey = "0xD9D476B39F713FD1";
          };
        };

        # Linux desktop configuration
        "thomas@linux-desktop" = home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            system = "x86_64-linux";
            config.allowUnfree = true;
          };
          modules = [ ./modules/profiles/linux-desktop.nix ];
          extraSpecialArgs = {
            username = "thomas";
            system = "x86_64-linux";
            inherit nvim-config;

            # GPG SSH keygrips for desktop (can be different from laptop)
            gpgSshKeygrips = [ ]; # Example: no GPG SSH on desktop
          };
        };
      };

      # macOS nix-darwin configurations
      darwinConfigurations = {
        # macOS work laptop
        "thomas@mac-work" = darwin.lib.darwinSystem {
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
              users.users.thomas.home = "/Users/thomas";

              home-manager.useGlobalPkgs = true;
              home-manager.users.thomas = import ./modules/profiles/darwin-work.nix;
              home-manager.extraSpecialArgs = {
                username = "thomas";
                system = "aarch64-darwin";
                inherit nvim-config;

                # GPG SSH keygrips for work mac
                gpgSshKeygrips = [ ]; # Example: no GPG SSH on work mac
              };
            }
          ];
        };

        # macOS personal laptop
        "thomas@mac-personal" = darwin.lib.darwinSystem {
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
              users.users.thomas.home = "/Users/thomas";

              home-manager.useGlobalPkgs = true;
              home-manager.users.thomas = import ./modules/profiles/darwin-personal.nix;
              home-manager.extraSpecialArgs = {
                username = "thomas";
                system = "aarch64-darwin";
                inherit nvim-config;

                # GPG SSH keygrips for laptop
                gpgSshKeygrips = [
                  {
                    keygrip = "A12EA21D952DB75C316811CFBB001B3577D62616";
                    comment = "GPG SSH key for Linux laptop";
                    flags = "0";
                  }
                ];

                # Git signing key
                signingKey = "0xD9D476B39F713FD1";
              };
            }
          ];
        };
      };
    };
}
