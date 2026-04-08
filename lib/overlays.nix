# =============================================================================
# ОВЕРЛЕИ NIXPKGS
# =============================================================================
# Расширяем pkgs: добавляем свои функции в lib и билдеры конфигураций.
# Список оверлеев применяется в flake.nix при импорте nixpkgs.
# =============================================================================
{ inputs, system }:

let
  # Информация о версии flake для lib
  libVersionOverlay = import "${inputs.nixpkgs}/lib/flake-version-info.nix" inputs.nixpkgs;

  # Оверлей lib: добавляет наши утилиты (exe) в pkgs.lib
  libOverlay = f: p: rec {
    libx = import ./. { inherit (p) lib; };
    lib = (p.lib.extend (_: _: {
      inherit (libx) exe;
    })).extend libVersionOverlay;
  };

  # Оверлей билдеров: mkHome и mkNixos для сборки конфигураций
  overlays = f: p: {
    builders = {
      mkHome = { pkgs ? f, extraHomeConfig ? { } }:
        import ../outputs/hm.nix {
          inherit extraHomeConfig inputs pkgs system;
          isDarwin = false;
        };

      mkNixos = { pkgs ? f, extraSystemConfig ? { } }:
        import ../outputs/os.nix { inherit extraSystemConfig inputs pkgs system; };
    };
  };
in
[
  libOverlay
  overlays
  inputs.niri-flake.overlays.niri
  inputs.claude-code.overlays.default
]
