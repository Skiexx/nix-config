{ pkgs, config, lib, ... }:

{
  imports = [
    ../common/packages.nix
    ./packages.nix
    ./git.nix
    ./neovim.nix
  ];

  home.username = "skiexx";
  home.homeDirectory = "/home/skiexx";

  home.sessionVariables = {
    EDITOR = "nvim";
    BROWSER = "vivaldi";
  };

  nixpkgs.config.allowUnfree = true;

  programs.fish = {
    enable = true;
  };

  home.stateVersion = "25.05";
}
