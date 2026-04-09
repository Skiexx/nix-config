# Конфигурация mise — универсальный менеджер версий языков
# Java (Liberica), Node.js и др.
{ pkgs, lib, ... }:

{
  programs.mise = {
    enable = true;
    enableFishIntegration = true;
  };

  home.packages = with pkgs; [
    gcc
    gnumake
    pkg-config
    gnupg
    php84
  ];
}
