# Конфигурация терминала Ghostty
{ config, pkgs, lib, ... }:

{
  programs.ghostty = {
    enable = true;
    settings = {
      font-family = "JetBrainsMono Nerd Font";
      font-size = 12;
      background = "#000000";
      background-opacity = 0.55;
      window-decoration = false;
      copy-on-select = "clipboard";
      confirm-close-surface = false;
    };
  };
}
