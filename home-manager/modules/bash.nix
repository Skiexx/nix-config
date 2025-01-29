{ config, pkgs, ... }:

{
  programs.bash = {
    enable = true;
    shellAliases = {
      nr = "sudo nixos-rebuild switch --flake ~/nix-config#nixos";
      hm = "home-manager switch --flake ~/nix-config#skiexx";
      update = "nix flake update && nr && hm";
    };
  };
}
