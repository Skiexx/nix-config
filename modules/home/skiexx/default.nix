{ pkgs, config, lib, inputs, ... }:

{
  imports = [
    ../common/packages.nix
    ./packages.nix
    ./git.nix
    ./neovim.nix
    ./java.nix
  ];

  home.username = "skiexx";
  home.homeDirectory = "/home/skiexx";

  home.sessionVariables = {
    EDITOR = "nvim";
    BROWSER = "vivaldi";
  };

  programs.neovim.languageSupport = {
    rust.enable = false;
    java.enable = true;
    php.enable = false;
    js.enable = true;
  };

  programs.fish = {
    enable = true;
  };

  home.stateVersion = "25.05";
}
