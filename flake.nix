{
  description = "Module NixOS + Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    astronvim = {
      url = "github:skiexx/astronvim_config";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, home-manager, astronvim, ... }@inputs: 
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      commonArgs = { inherit inputs system; };
    in
    {
      nixosConfigurations = {
        "workstation" = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = commonArgs;

	  modules = [
	    ./hosts/workstation/configuration.nix
	    ./hosts/workstation/hardware-configuration.nix
	    home-manager.nixosModules.home-manager
	    {
	      home-manager.useGlobalPkgs = true;
	      home-manager.useUserPackages = true;
	      home-manager.extraSpecialArgs = commonArgs;
	      home-manager.users.skiexx = import ./modules/home/skiexx/default.nix commonArgs;
	    }
	  ];
        };
      };
    };
}
