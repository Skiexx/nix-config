{ config, pkgs, ... }:

{
  services = {
    xserver.enable = true;
    displayManager = {
      sddm = {
        enable = true;
        wayland.enable = true;
      };
      autoLogin = {
        enable = true;
        user = "skiexx";
      };
      defaultSession = "hyprland";
    };
  };

  programs.hyprland.enable = true;
  programs.xwayland.enable = true;

  environment.systemPackages = with pkgs; [
    waybar
    rofi-wayland
    dunst
    mako
    alacritty
    kitty
    xfce.thunar
    pavucontrol
    wl-clipboard
    grim
    slurp
    swaylock
    swayidle
    brightnessctl
    playerctl
    networkmanagerapplet
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
