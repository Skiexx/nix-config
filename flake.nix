{
  description = "Module NixOS + Home Manager configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, ... }@inputs: 
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
	    }
	  ];
        };
      };
    };
}
