# Конфигурация Git (GPG-подпись, SSH, GitHub CLI)
{ lib, pkgs, isDarwin ? false, ... }:

let
  gpgKeyId = "39C306A3C903BF4D";
in
{
  programs.git = {
    enable = true;
    signing = {
      key = gpgKeyId;
      signByDefault = true;
      format = "openpgp";
    };
    settings = {
      user.name = "Skiexx";
      user.email = "krupashow@yandex.ru";
      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;
      diff.colorMoved = "default";
      merge.conflictstyle = "diff3";
      gpg.program = "${pkgs.gnupg}/bin/gpg";
      url."git@github.com:".insteadOf = "https://github.com/";
    };
  };

  # GitHub CLI
  xdg.configFile."gh/config.yml".force = true;
  programs.gh = {
    enable = true;
    gitCredentialHelper.enable = true;
    settings.git_protocol = "ssh";
  };
}
