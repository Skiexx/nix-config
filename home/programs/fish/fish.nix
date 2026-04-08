# Конфигурация оболочки Fish и промпта Starship
{ config, pkgs, lib, ... }:

{
  programs.fish = {
    enable = true;

    # Fish-idiomatic abbreviations (expand inline so you see the full command)
    shellAbbrs = {
      ll = "eza -lah";
      ls = "eza";
      cat = "bat";

      # Git — остальные алиасы из plugin-git (gc, gss, gco, gp, gl и ~100 других)

      # NixOS
      nrs = "sudo nixos-rebuild switch --flake .";
      nrt = "sudo nixos-rebuild test --flake .";
      hms = "home-manager switch --flake .";
    };

    interactiveShellInit = ''
      # Disable greeting
      set -g fish_greeting

      # Auto-cd (type directory name to cd into it)
      set -g fish_features auto_cd
    '';

    plugins = [
      { name = "autopair"; src = pkgs.fishPlugins.autopair.src; }
      { name = "done"; src = pkgs.fishPlugins.done.src; }
      { name = "plugin-git"; src = pkgs.fishPlugins.plugin-git.src; }
      { name = "bang-bang"; src = pkgs.fishPlugins.bang-bang.src; }
      { name = "bass"; src = pkgs.fishPlugins.bass.src; }
      { name = "fzf-fish"; src = pkgs.fishPlugins.fzf-fish.src; }
      { name = "fish-you-should-use"; src = pkgs.fishPlugins.fish-you-should-use.src; }
      { name = "colored-man-pages"; src = pkgs.fishPlugins.colored-man-pages.src; }
      { name = "grc"; src = pkgs.fishPlugins.grc.src; }
      { name = "sponge"; src = pkgs.fishPlugins.sponge.src; }
      { name = "puffer-fish"; src = pkgs.fetchFromGitHub {
        owner = "nickeb96"; repo = "puffer-fish";
        rev = "83174b07de60078be79985ef6123d903329622b8";
        hash = "sha256-Dhx5+XRxJvlhdnFyimNxFyFiASrGU4ZwyefsDwtKnSg=";
      }; }
    ];
  };

  # Автодополнение для команды mikoshi
  xdg.configFile."fish/completions/mikoshi.fish".text = ''
    # Основные опции
    complete -c mikoshi -n '__fish_use_subcommand' -l switch -d 'Пересобрать конфигурацию'
    complete -c mikoshi -n '__fish_use_subcommand' -l update -d 'Обновить flake inputs'
    complete -c mikoshi -n '__fish_use_subcommand' -l gc -d 'Очистить старые поколения'
    complete -c mikoshi -n '__fish_use_subcommand' -l diff -d 'Diff между поколениями'
    complete -c mikoshi -n '__fish_use_subcommand' -l list -d 'Список поколений'
    complete -c mikoshi -n '__fish_use_subcommand' -l rollback -d 'Откатить на предыдущее поколение'
    complete -c mikoshi -n '__fish_use_subcommand' -l check -d 'Проверить flake'
    complete -c mikoshi -n '__fish_use_subcommand' -l search -d 'Поиск пакета в nixpkgs'
    complete -c mikoshi -n '__fish_use_subcommand' -l why -d 'Зависимость пакета в closure'
    complete -c mikoshi -n '__fish_use_subcommand' -l config -d 'Настройки скрипта'
    complete -c mikoshi -n '__fish_use_subcommand' -l help -d 'Справка'

    # --switch targets
    complete -c mikoshi -n '__fish_seen_argument -l switch' -f -a 'system' -d 'Пересобрать NixOS'
    complete -c mikoshi -n '__fish_seen_argument -l switch' -f -a 'hm' -d 'Пересобрать Home Manager'
    complete -c mikoshi -n '__fish_seen_argument -l switch' -f -a 'all' -d 'Пересобрать оба'

    # --rollback targets
    complete -c mikoshi -n '__fish_seen_argument -l rollback' -f -a 'system' -d 'Откатить NixOS'
    complete -c mikoshi -n '__fish_seen_argument -l rollback' -f -a 'hm' -d 'Откатить Home Manager'

    # --config targets
    complete -c mikoshi -n '__fish_seen_argument -l config' -f -a 'flake' -d 'Путь до flake'
    complete -c mikoshi -n '__fish_seen_argument -l config' -f -a 'host' -d 'Hostname машины'
    complete -c mikoshi -n '__fish_seen_argument -l config' -f -a 'profile' -d 'Профиль HM'

    # --switch hm profiles
    complete -c mikoshi -n '__fish_seen_argument -l switch; and __fish_seen_subcommand_from hm all' -f -a 'niri default' -d 'Профиль HM'
  '';

  # Starship prompt (shell-agnostic)
  programs.starship = {
    enable = true;
    settings = {
      add_newline = true;

      format = lib.concatStrings [
        "$username"
        "$hostname"
        "$directory"
        "$git_branch"
        "$git_status"
        "$nix_shell"
        "$character"
      ];

      character = {
        success_symbol = "[](bold green)";
        error_symbol = "[](bold red)";
      };

      directory = {
        truncation_length = 3;
        truncate_to_repo = true;
        style = "bold cyan";
        read_only = " 󰌾";
      };

      git_branch = {
        symbol = " ";
        style = "bold purple";
      };

      git_status = {
        style = "bold yellow";
        conflicted = "󰦖 ";
        ahead = "⇡\${count}";
        behind = "⇣\${count}";
        diverged = "⇕⇡\${ahead_count}⇣\${behind_count}";
        untracked = " 󰓧 ";
        stashed = " 󰋞 ";
        modified = " 󰏫 ";
        staged = " 󰄬 ";
        renamed = " 󰁕 ";
        deleted = " 󰆴 ";
      };

      nix_shell = {
        symbol = "  ";
        format = "via [$symbol$state]($style) ";
        style = "bold blue";
      };

      username = {
        show_always = true;
        format = "[$user]($style) ";
        style_user = "bold yellow";
      };

      hostname = {
        ssh_only = false;
        format = "on [$hostname]($style) ";
        style = "bold green";
        disabled = true;
      };
    };
  };
}
