{ config, pkgs, lib, ... }:

let
  moduleDir = builtins.toPath ./modules;
  moduleFiles = builtins.attrNames (builtins.readDir moduleDir);
  modulePaths = map (file: "${toString moduleDir}/${file}") (builtins.filter (f: lib.hasSuffix ".nix" f) moduleFiles);
in
{
  imports = builtins.concatLists [
    [ ./hardware-configuration.nix ]
    [ ./modules/packages.nix ]
    [ ./modules/shell.nix ]
    modulePaths
  ];

  system.stateVersion = "24.11";
}
