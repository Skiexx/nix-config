{ config, pkgs, lib, inputs, system, ... }:

{
  imports = [
    ../../modules/system/base.nix
    ../../modules/system/services.nix
    ../../modules/system/plasma.nix
  ];

  networking.hostName = "nixos";
  time.timeZone = "Asia/Tomsk";
  i18n.defaultLocale = "en_US.UTF-8";

  users.users.skiexx = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" "networkmanager" ];
    shell = pkgs.fish;
  };

  home-manager.users.skiexx = import ../../modules/home/skiexx/default.nix;

  system.stateVersion = "25.05";
}
