{
  description = "NixOS + Home Manager Configuration";
  
  inputs = {
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager/release-24.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs-stable";
  };

  outputs = inputs@{ self, nixpkgs-stable, nixpkgs-unstable, home-manager, ... }: {
    nixosConfigurations = {
      nixos = nixpkgs-stable.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          ./nixos/configuration.nix
          home-manager.nixosModules.home-manager
          {
	    nixpkgs.overlays = [
              (final: prev: {
                unstable = import nixpkgs-unstable {
                  system = final.system;
                  config = final.config;
                };
              })
            ];
            nixpkgs.config.allowUnfree = true;

            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.skiexx = import ./home-manager/home.nix;
          }
        ];
      };
    };

    homeConfigurations = {
      skiexx = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs-stable.legacyPackages.x86_64-linux;
        modules = [ ./home-manager/home.nix ];
      };
    };
  };
}
