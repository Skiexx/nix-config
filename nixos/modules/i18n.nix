{ config, pkgs, ... }:

{
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "eurlatgr";
    useXkbConfig = true;
  };

  services.xserver.xkb.layout = "us,ru";
}
