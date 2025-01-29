{ config, pkgs, ... }:

{
  users.users.skiexx = {
    initialPassword = "password";
    isNormalUser = true;
    extraGroups = [ "wheel" "networkmanager" ];
    description = "Skiexx";
  };
}
