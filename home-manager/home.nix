{ config, pkgs, lib, ... }:

let
  moduleDir = builtins.toPath ./modules;
  moduleFiles = builtins.attrNames (builtins.readDir moduleDir);
  modulePaths = map (file: "${toString moduleDir}/${file}") (builtins.filter (f: lib.hasSuffix ".nix" f) moduleFiles);
in
{
  nixpkgs.config.allowUnfree = true;

  programs.home-manager.enable = true;

  home.username = "skiexx";
  home.homeDirectory = "/home/skiexx";

  imports = modulePaths;

  home.packages = with pkgs; [
    htop
    yandex-music
    unzip
  ];

  home.stateVersion = "24.11";
}
