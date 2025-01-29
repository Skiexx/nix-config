{ config, pkgs, ... }:

{
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    useXkbConfig = true;
  };
  services.xserver.xkb.layout = "us,ru";
}
