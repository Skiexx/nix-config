{ pkgs, ... }:

{
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Skiexx";
        email = "codeskiexx@yandex.ru";
      };

      init.defaultBranch = "main";
      pull.rebase = false;
    };
  };
}
