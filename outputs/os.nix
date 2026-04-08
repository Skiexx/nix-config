# =============================================================================
# БИЛДЕР СИСТЕМНЫХ КОНФИГУРАЦИЙ NIXOS
# =============================================================================
# Создаёт конфигурации NixOS для каждой машины из списка hosts.
# Общая база (system/configuration.nix) + машино-специфичные модули.
#
# sudo nixos-rebuild switch --flake .#<hostname>
# =============================================================================
{ extraSystemConfig, inputs, system, pkgs, ... }:

let
  inherit (inputs.nixpkgs.lib) nixosSystem;
  inherit (pkgs) lib;

  # Список хостов; для каждого нужна директория system/machine/<hostname>/
  hosts = [ "mikoshi" ];

  # Базовые модули, общие для всех машин
  modules' = [
    ../system/configuration.nix
    inputs.sops-nix.nixosModules.sops
    extraSystemConfig
    { nix.registry.nixpkgs.flake = inputs.nixpkgs; }
  ];

  # Собирает конфигурацию NixOS для одного хоста
  make = host: {
    ${host} = nixosSystem {
      inherit lib pkgs system;
      specialArgs = { inherit inputs; };
      # Базовые модули + машино-специфичные из system/machine/<host>
      modules = modules' ++ [ ../system/machine/${host} ];
    };
  };
in
# Объединяем конфигурации всех машин в один attrset
lib.mergeAttrsList (map make hosts)
