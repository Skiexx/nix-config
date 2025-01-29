{ config, pkgs, ... }:

{
  security.sudo.extraRules = [
    {
      users = [ "skiexx" ];
      commands = [
        { command = "/run/current-system/sw/bin/nixos-rebuild"; options = [ "NOPASSWD" ]; }
      ];
    }
  ];
}
