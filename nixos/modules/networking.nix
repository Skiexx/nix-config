{ config, pkgs, ... }:

{
  networking = {
    hostName = "nixos";
    networkmanager.enable = true;
    useDHCP = false;
    firewall.enable = false;
  };
}
