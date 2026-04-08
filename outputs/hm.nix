# =============================================================================
# БИЛДЕР КОНФИГУРАЦИЙ HOME MANAGER
# =============================================================================
{ extraHomeConfig, inputs, system, pkgs, isDarwin ? false, ... }:

let
  modules' = [
    { nix.registry.nixpkgs.flake = inputs.nixpkgs; }
    inputs.sops-nix.homeManagerModules.sops
    extraHomeConfig
  ];

  mkHome = { hidpi ? false, mutable ? false, mods ? [ ] }:
    inputs.home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules = modules' ++ mods;
      extraSpecialArgs = { inherit inputs isDarwin; };
    };
in
{
  # Минимальный профиль без оконного менеджера
  default = mkHome {
    mods = [ ../home/shared ];
  };

  # Полный рабочий стол с Niri WM
  niri = mkHome {
    mods = [ ../home/wm/niri ];
  };
}
