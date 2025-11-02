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
    homeConfigurations = {
      # Linux config
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

      darwinConfigurations."thomas@mac" = darwin.lib.darwinSystem {
        system = "aarch64-darwin"; # Use "x86_64-darwin" for Intel Macs
        modules = [
          ./darwin/configuration.nix

          { nixpkgs.config.allowUnfree = true; }

          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.thomas = import ./modules/home.nix;
            home-manager.extraSpecialArgs = {
              username = "thomas";
              system = "aarch64-darwin";
            };
          }
        ];
      };
    };
  };
}
