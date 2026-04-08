# Пользовательские скрипты (собираются через callPackage)
{ callPackage, ... }:

{
  mikoshi = callPackage ./mikoshi.nix { };
}
