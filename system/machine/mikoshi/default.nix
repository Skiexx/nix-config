{
  config,
  lib,
  pkgs,
  ...
}: {
  # === ИМПОРТЫ ===
  imports = [
    ./hardware-configuration.nix
    ./video.nix
    ../../wm/niri.nix
  ];

  # === СЕТЬ ===
  networking.hostName = "mikoshi";

  # === ПРОГРАММЫ (ИГРЫ) ===
  programs.gamemode.enable = true;
  programs.steam = {
    dedicatedServer.openFirewall = true;
    enable = true;
    remotePlay.openFirewall = true;
  };
}
