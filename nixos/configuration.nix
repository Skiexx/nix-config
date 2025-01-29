{ config, pkgs, lib, inputs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ./modules/nix.nix
      ./modules/boot.nix
      ./modules/networking.nix
      ./modules/time.nix
      ./modules/i18n.nix
      ./modules/users.nix
      ./modules/packages.nix
      ./modules/ssh.nix
      ./modules/security.nix
      ./modules/hyprland.nix
    ];

  system.stateVersion = "24.11";
}
