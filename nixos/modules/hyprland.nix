{ config, pkgs, ... }:

{
  programs.hyprland.enable = true;
  programs.xwayland.enable = true;

  environment.systemPackages = with pkgs; [
    # Панель и уведомления
    waybar
    rofi-wayland
    dunst
    mako

    # Терминалы
    alacritty
    kitty

    # Файловые менеджеры
    xfce.thunar

    # Аудио и мультимедиа
    pavucontrol
    playerctl
    networkmanagerapplet

    # Управление клипбордом и скриншотами
    wl-clipboard
    grim
    slurp

    # Блок и энергосбережение экрана
    swaylock
    swayidle
    brightnessctl
  ];

  #  hardware.graphics = {
  #  enable = true;
  # enable32Bit = true;
  #};

  environment.sessionVariables = {
    WLR_RENDERER_ALLOW_SOFTWARE = "1";
    NIXOS_OZONE_WL = "1";
    WLR_NO_HARDWARE_CURSORS = "1";
  };
}
