{ config, pkgs, ... }:

{
  fonts = {
    enableDefaultPackages = true;
    fontconfig.enable = true;
    packages = with pkgs; [
      (nerdfonts.override { fonts = [ "FiraCode" ]; })
      noto-fonts-emoji
      twemoji-color-font
    ];
  };
}
