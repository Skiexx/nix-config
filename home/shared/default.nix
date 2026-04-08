# =============================================================================
# Общая пользовательская конфигурация
# =============================================================================
# Базовая конфигурация, включаемая во ВСЕ профили Home Manager.
# Профили (niri и др.) расширяют эту базу своими пакетами и настройками.
# =============================================================================
{
  pkgs,
  lib,
  isDarwin ? false,
  ...
}: let
  username = "skiexx";
  homeDirectory = "/home/${username}";
  configHome = "${homeDirectory}/.config";

  # Пользовательские скрипты (mikoshi и др.)
  scripts = pkgs.callPackage ../scripts {};

  packages = with pkgs;
    [
      # --- Мониторинг системы ---
      fastfetch
      bottom     # btm — замена htop
      dust       # визуализация диска

      # --- Навигация по файлам ---
      eza        # замена ls
      fd         # замена find
      tree

      # --- Поиск ---
      ripgrep    # rg — замена grep
      grc        # подсветка вывода команд (ping, docker, podman и др.)

      # --- Приложения ---
      bolt-launcher
      lutris
      signal-desktop
      vlc
      yubioath-flutter
      obsidian
      ayugram-desktop
      spotify
      linux-wallpaperengine

      # --- Системные утилиты ---
      xhost
      xdg-utils
      vulkan-tools

      # --- Файлы ---
      unzip
      zip

      # --- Разработка ---
      git
      opencode
      postman
      lazygit
      glab       # GitLab CLI
      bun        # JavaScript runtime

      # --- Claude через прокси ---
      (writeShellScriptBin "claude" ''
        export ALL_PROXY=socks5://127.0.0.1:1080
        export HTTP_PROXY=http://127.0.0.1:1080
        export HTTPS_PROXY=http://127.0.0.1:1080
        exec ${claude-code}/bin/claude "$@"
      '')
      (writeShellScriptBin "claude-node" ''
        export ALL_PROXY=socks5://127.0.0.1:1080
        export HTTP_PROXY=http://127.0.0.1:1080
        export HTTPS_PROXY=http://127.0.0.1:1080
        exec ${claude-code-node}/bin/claude "$@"
      '')

      # --- Секреты ---
      age
      sops

      # --- Языки программирования ---
      python3
      nodejs
      go
      rustup       # Rust toolchain (rustc, cargo, rustfmt, clippy)
    ]
    ++ (lib.attrValues (lib.filterAttrs (n: v: !lib.isFunction v) scripts));
in {
  programs.home-manager.enable = true;

  imports = [
    ../themes
    ./programs.nix
    ./services.nix
    ./secrets.nix
  ];

  xdg = {
    inherit configHome;
    enable = true;

    # Переопределяем стандартный .desktop Postman чтобы он запускался через прокси
    desktopEntries.postman = {
      name = "Postman";
      comment = "API-тестирование через прокси";
      exec = "env HTTP_PROXY=http://127.0.0.1:1080 HTTPS_PROXY=http://127.0.0.1:1080 postman %U";
      icon = "postman";
      terminal = false;
      type = "Application";
      categories = [ "Development" ];
    };

    mimeApps = {
      enable = true;
      defaultApplications = {
        "text/html" = "vivaldi-stable.desktop";
        "x-scheme-handler/http" = "vivaldi-stable.desktop";
        "x-scheme-handler/https" = "vivaldi-stable.desktop";
        "x-scheme-handler/about" = "vivaldi-stable.desktop";
        "x-scheme-handler/unknown" = "vivaldi-stable.desktop";
      };
    };
  };

  home = {
    inherit username homeDirectory packages;
    stateVersion = "24.11";
    sessionVariables = {
      EDITOR = "nvim";
    };
  };

  systemd.user.startServices = "sd-switch";
}
