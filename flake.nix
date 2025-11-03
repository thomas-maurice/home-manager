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
  };

  outputs = { nixpkgs, home-manager, darwin, ... }: {
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
        config.allowUnfree = true;
      };
      modules = [
        ./darwin/configuration.nix
        home-manager.darwinModules.home-manager
        {
          # needed otherwise nix-darwin will shit itself
          users.users.thomas.home = "/Users/thomas";

          # home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.thomas = import ./modules/home.nix;
          home-manager.sharedModules = [
            {
              nixpkgs.config.allowUnfree = true;
            }
          ];
          home-manager.extraSpecialArgs = {
            username = "thomas";
            system = "aarch64-darwin";
          };
        }
      ];
    };
  };
}
