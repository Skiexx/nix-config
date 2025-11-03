{ config, pkgs, lib, inputs, system, ... }:

{
  imports = [
    ../../modules/system/base.nix
    ../../modules/system/services.nix
    ../../modules/system/plasma.nix
    ../../modules/system/docker.nix
  ];

  networking.hostName = "nixos";
  time.timeZone = "Asia/Tomsk";
  i18n.defaultLocale = "en_US.UTF-8";

  users.users.skiexx = {
    isNormalUser = true;
    extraGroups = [ "wheel" "docker" "networkmanager" ];
    shell = pkgs.fish;
  };

  fonts.packages = with pkgs; [
    (nerdfonts.override { fonts = [ "FiraCode" "JetBrainsMono" ]; })
  ];

  nixpkgs.config.allowUnfree = true;

  system.stateVersion = "25.05";
}
