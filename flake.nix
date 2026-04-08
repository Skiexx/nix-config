# =============================================================================
# ASTHENIA — КОНФИГУРАЦИЯ FLAKE
# =============================================================================
# Точка входа в конфигурацию NixOS.
#
# Система: sudo nixos-rebuild switch --flake .#mikoshi
# Пользователь: home-manager switch --flake .#niri
# =============================================================================
{
  description = "NixOS Configuration with Home Manager";

  nixConfig = {
    extra-substituters = [
      "https://cache.nixos.org"
      "https://claude-code.cachix.org"
    ];
    extra-trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "claude-code.cachix.org-1:YeXf2aNu7UTX8Vwrze0za1WEDS+4DuI2kVeWEE4fsRk="
    ];
  };

  inputs = {
    # --- Ядро ---
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Stable — для пакетов, которым нужна стабильность
    # Использование: inputs.nixpkgs-stable.legacyPackages.${system}.<пакет>
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-24.11";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake-schemas.url = "github:DeterminateSystems/flake-schemas";

    # --- Секреты ---
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # --- Оконный менеджер и рабочий стол ---
    niri-flake = {
      url = "github:sodiboo/niri-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    dms = {
      url = "github:AvengeMedia/DankMaterialShell";
    };

    # --- Приложения ---
    nixcord = {
      url = "github:kaylorben/nixcord";
    };

    claude-code = {
      url = "github:sadjow/claude-code-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs = inputs @ {
    self,
    nixpkgs,
    home-manager,
    flake-schemas,
    ...
  }: let
    system = "x86_64-linux";

    overlays = import ./lib/overlays.nix { inherit inputs system; };

    pkgs = import nixpkgs {
      inherit overlays system;
      config = {
        allowUnfree = true;
      };
    };
  in {
    homeConfigurations = pkgs.builders.mkHome {};

    nixosConfigurations = pkgs.builders.mkNixos {};

    out = { inherit pkgs overlays; };

    schemas =
      flake-schemas.schemas
      // import ./lib/schemas.nix { inherit (inputs) flake-schemas; };
  };
}
