{ writeShellScriptBin, ... }:

writeShellScriptBin "mikoshi" ''
  set -e

  # ==========================================================================
  # Конфигурация
  # ==========================================================================
  CONFIG_DIR="$HOME/.config/mikoshi"
  CONFIG_FILE="$CONFIG_DIR/config"

  # Значения по умолчанию
  FLAKE_DIR="$HOME/.config/mikoshi"
  HOSTNAME="mikoshi"
  DEFAULT_HM_PROFILE="niri"

  # Загрузка конфигурации из файла (если существует)
  load_config() {
    if [[ -f "$CONFIG_FILE" ]]; then
      source "$CONFIG_FILE"
    fi
  }

  # Сохранение конфигурации
  save_config() {
    mkdir -p "$CONFIG_DIR"
    cat > "$CONFIG_FILE" << CONF
# mikoshi — конфигурация скрипта пересборки NixOS
# Сгенерировано: $(date -Iseconds)

# Путь до flake-конфигурации NixOS
FLAKE_DIR="$FLAKE_DIR"

# Hostname машины (для nixos-rebuild)
HOSTNAME="$HOSTNAME"

# HM-профиль по умолчанию (если не удалось определить автоматически)
DEFAULT_HM_PROFILE="$DEFAULT_HM_PROFILE"
CONF
    echo "Конфигурация сохранена в $CONFIG_FILE"
  }

  # Загрузить конфиг при старте
  load_config

  # Автоопределение текущего профиля Home Manager
  detect_hm_profile() {
    local current_gen="$HOME/.local/state/nix/profiles/home-manager"
    if [[ -L "$current_gen" ]]; then
      local profile_path=$(readlink -f "$current_gen")
      if [[ "$profile_path" =~ homeConfigurations\.([^/]+) ]]; then
        echo "''${BASH_REMATCH[1]}"
        return 0
      fi
    fi
    echo "$DEFAULT_HM_PROFILE"
  }

  show_help() {
    cat << EOF
mikoshi — помощник пересборки NixOS и Home Manager

Использование:
  mikoshi [ОПЦИИ]

Пересборка:
  --switch system         Пересобрать и переключить NixOS
  --switch hm [ПРОФИЛЬ]  Пересобрать и переключить Home Manager
  --switch all [ПРОФИЛЬ] Пересобрать оба (NixOS + HM)
  --update               Обновить flake inputs перед пересборкой

Обслуживание:
  --gc                   Очистить старые поколения (garbage collect)
  --diff                 Показать diff между поколениями системы
  --list                 Показать список поколений
  --rollback system      Откатить NixOS на предыдущее поколение
  --rollback hm          Показать поколения Home Manager

Утилиты:
  --check                Проверить flake (без сборки)
  --search <пакет>       Поиск пакета в nixpkgs
  --why <пакет>          Показать зависимость пакета в closure

Конфигурация:
  --config               Показать текущую конфигурацию
  --config flake <путь>  Установить путь до flake-конфигурации
  --config host <имя>    Установить hostname
  --config profile <имя> Установить профиль HM по умолчанию

  --help                 Показать эту справку

Текущая конфигурация:
  FLAKE_DIR=$FLAKE_DIR
  HOSTNAME=$HOSTNAME
  DEFAULT_HM_PROFILE=$DEFAULT_HM_PROFILE

Примеры:
  mikoshi --switch all               # Пересобрать всё
  mikoshi --update --switch all      # Обновить + пересобрать
  mikoshi --gc                       # Очистить мусор
  mikoshi --config flake ~/nixos     # Указать путь до конфига
EOF
  }

  UPDATE=false
  SWITCH_SYSTEM=false
  SWITCH_HM=false
  HM_PROFILE=""

  if [[ $# -eq 0 ]]; then
    show_help
    exit 0
  fi

  while [[ $# -gt 0 ]]; do
    case $1 in
      --switch)
        case $2 in
          system|nixos)
            SWITCH_SYSTEM=true
            shift 2
            ;;
          hm)
            SWITCH_HM=true
            shift 2
            if [[ $# -gt 0 && ! "$1" =~ ^-- ]]; then
              HM_PROFILE="$1"
              shift
            fi
            ;;
          all)
            SWITCH_SYSTEM=true
            SWITCH_HM=true
            shift 2
            if [[ $# -gt 0 && ! "$1" =~ ^-- ]]; then
              HM_PROFILE="$1"
              shift
            fi
            ;;
          *)
            echo "Ошибка: неверная цель '$2'. Допустимые: system, hm, all"
            exit 1
            ;;
        esac
        ;;
      --update)
        UPDATE=true
        shift
        ;;
      --config)
        case $2 in
          flake)
            if [[ -z "$3" ]]; then
              echo "Ошибка: --config flake требует путь"
              exit 1
            fi
            FLAKE_DIR="$(realpath "$3")"
            save_config
            shift 3
            exit 0
            ;;
          host)
            if [[ -z "$3" ]]; then
              echo "Ошибка: --config host требует имя"
              exit 1
            fi
            HOSTNAME="$3"
            save_config
            shift 3
            exit 0
            ;;
          profile)
            if [[ -z "$3" ]]; then
              echo "Ошибка: --config profile требует имя"
              exit 1
            fi
            DEFAULT_HM_PROFILE="$3"
            save_config
            shift 3
            exit 0
            ;;
          ""|--*)
            echo "=== Конфигурация mikoshi ==="
            echo "Файл конфига: $CONFIG_FILE"
            echo ""
            echo "FLAKE_DIR=$FLAKE_DIR"
            echo "HOSTNAME=$HOSTNAME"
            echo "DEFAULT_HM_PROFILE=$DEFAULT_HM_PROFILE"
            if [[ "$2" == "" ]]; then shift; else true; fi
            exit 0
            ;;
          *)
            echo "Ошибка: неизвестный параметр конфига '$2'"
            echo "Допустимые: flake, host, profile (или без параметра для просмотра)"
            exit 1
            ;;
        esac
        ;;
      --gc)
        echo "Очистка мусора (пользователь)..."
        nix-collect-garbage -d
        echo "Очистка мусора (система)..."
        sudo nix-collect-garbage -d
        echo "Оптимизация store..."
        nix store optimise
        echo "Готово!"
        exit 0
        ;;
      --diff)
        echo "Diff поколений системы:"
        nix store diff-closures /nix/var/nix/profiles/system-*-link | head -50
        exit 0
        ;;
      --list)
        echo "Поколения NixOS:"
        sudo nix-env --list-generations --profile /nix/var/nix/profiles/system
        echo ""
        echo "Поколения Home Manager:"
        home-manager generations | head -20
        exit 0
        ;;
      --rollback)
        case $2 in
          system)
            echo "Откат NixOS..."
            sudo nixos-rebuild switch --rollback
            shift 2
            exit 0
            ;;
          hm)
            echo "Поколения Home Manager:"
            home-manager generations
            echo ""
            echo "Для отката: home-manager switch --flake $FLAKE_DIR#<профиль>"
            shift 2
            exit 0
            ;;
          *)
            echo "Ошибка: --rollback требует 'system' или 'hm'"
            exit 1
            ;;
        esac
        ;;
      --check)
        echo "Проверка flake..."
        cd "$FLAKE_DIR"
        nix flake check
        echo "Flake валиден!"
        exit 0
        ;;
      --search)
        if [[ -z "$2" ]]; then
          echo "Ошибка: --search требует имя пакета"
          exit 1
        fi
        nix search nixpkgs#"$2"
        shift 2
        exit 0
        ;;
      --why)
        if [[ -z "$2" ]]; then
          echo "Ошибка: --why требует имя пакета"
          exit 1
        fi
        nix why-depends /nix/var/nix/profiles/system nixpkgs#"$2" 2>/dev/null || \
          echo "Пакет '$2' не найден в closure системы"
        shift 2
        exit 0
        ;;
      --help|-h)
        show_help
        exit 0
        ;;
      *)
        echo "Ошибка: неизвестная опция '$1'"
        show_help
        exit 1
        ;;
    esac
  done

  # Валидация пути до flake
  if [[ ! -f "$FLAKE_DIR/flake.nix" ]]; then
    echo "Ошибка: flake.nix не найден в $FLAKE_DIR"
    echo "Используйте: mikoshi --config flake <путь>"
    exit 1
  fi

  if [[ "$UPDATE" == true ]]; then
    echo "Обновление flake inputs..."
    cd "$FLAKE_DIR"
    nix flake update
  fi

  if [[ "$SWITCH_SYSTEM" == true ]]; then
    echo "Переключение NixOS ($HOSTNAME)..."
    sudo nixos-rebuild switch --flake "$FLAKE_DIR#$HOSTNAME"
  fi

  if [[ "$SWITCH_HM" == true ]]; then
    if [[ -z "$HM_PROFILE" ]]; then
      HM_PROFILE=$(detect_hm_profile)
      echo "Определён профиль HM: $HM_PROFILE"
    fi
    echo "Переключение Home Manager ($HM_PROFILE)..."
    home-manager switch --flake "$FLAKE_DIR#$HM_PROFILE"
  fi

  echo "Готово!"
''
