{ config, pkgs, ... }:

{
  programs.git = {
    enable = true;

    userName = "Skiexx";
    userEmail = "codeskiexx@yandex.ru";

    extraConfig = {
      color.ui = "auto";
      core.editor = "nvim";
      pull.rebase = false;
      init.defaultBranch = "main";
    };

    ignores = [
      ".idea/"
      ".vscode/"
      "*.log"
      "node_modules/"
      "vendor/"
    ];
  };
}
