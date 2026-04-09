{
  pkgs,
  config,
  lib,
  isDarwin ? false,
  ...
}: {
  imports = [
    # --- Инструменты разработки ---
    ../programs/git/git.nix
    ../programs/vscode/vscode.nix
    ../programs/zed-editor/zed-editor.nix
    ../programs/crush/crush.nix

    # --- Шелл и терминал ---
    ../programs/fish/fish.nix
    ../programs/ghostty/ghostty.nix
    ../programs/zellij/zellij.nix

    # --- Приложения ---
    ../programs/chrome/chrome.nix
    ../programs/discord/discord.nix
    ../programs/yazi/yazi.nix
    ../programs/fuzzle/fuzzle.nix
    ../programs/vivaldi/vivaldi.nix
    ../programs/intellij/intellij.nix
    ../programs/obs/obs.nix
    ../programs/sing-box/sing-box.nix
    ../programs/dms/dms.nix
    ../programs/neovim/neovim.nix
    ../programs/mise/mise.nix
  ];

  programs = {
    bat.enable = true;

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    fzf = {
      enable = true;
      defaultCommand = "fd --type file --follow";
      defaultOptions = ["--height 20%"];
    };

    htop = {
      enable = true;
      settings = {
        sort_direction = true;
        sort_key = "PERCENT_CPU";
      };
    };

    jq.enable = true;
  };
}
