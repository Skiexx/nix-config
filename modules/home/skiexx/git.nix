{ pkgs, ... }:

{
  programs.git = {
    enable = true;
    extraConfig = {
      user = {
        name = "Skiexx";
        email = "codeskiexx@yandex.ru";
      };

      init.defaultBranch = "main";
      pull.rebase = false;
    };
  };
}
