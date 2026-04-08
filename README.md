# Mikoshi — конфигурация NixOS

Модульная конфигурация NixOS на основе Niri (Wayland), Home Manager и flakes.
Форк [infktd/asthenia](https://github.com/infktd/asthenia), адаптированный под мои нужды.

## Быстрый старт

```bash
# Клонирование
git clone <repo> ~/.config/mikoshi
cd ~/.config/mikoshi

# Первоначальная настройка секретов
mkdir -p ~/.config/sops/age
age-keygen -o ~/.config/sops/age/keys.txt
# Скопировать public key в .sops.yaml, затем:
sops secrets/secrets.yaml

# Сборка системы
sudo nixos-rebuild switch --flake .#mikoshi

# Сборка пользовательской конфигурации
home-manager switch --flake .#niri

# Перезагрузка для запуска Niri
systemctl reboot
```

## Скрипт `mikoshi`

После первой сборки доступен скрипт-помощник:

```bash
mikoshi --switch all               # Пересобрать NixOS + Home Manager
mikoshi --update --switch all      # Обновить inputs + пересобрать
mikoshi --gc                       # Очистить старые поколения
mikoshi --diff                     # Diff между поколениями
mikoshi --list                     # Список поколений
mikoshi --rollback system          # Откатить систему
mikoshi --check                    # Проверить flake
mikoshi --search <пакет>           # Поиск пакета
mikoshi --config                   # Показать конфигурацию скрипта
mikoshi --config flake ~/nixos     # Указать путь до flake
```

Конфигурация скрипта хранится в `~/.config/mikoshi/config`.

## Архитектура

Двухуровневая: система (NixOS, sudo) и пользователь (Home Manager, без sudo).

```
flake.nix                         # Точка входа
├── lib/overlays.nix              # Оверлеи и функции-строители (mkHome, mkNixos)
├── outputs/
│   ├── hm.nix                    # Профили Home Manager (default, niri)
│   └── os.nix                    # Системные конфигурации (mikoshi)
├── system/
│   ├── configuration.nix         # Базовая конфигурация NixOS
│   ├── machine/mikoshi/          # Конфиг конкретной машины
│   │   ├── hardware-configuration.nix
│   │   └── video.nix             # AMD GPU
│   └── wm/niri.nix               # Системные сервисы Niri + DMS
├── home/
│   ├── shared/                   # Общая конфигурация пользователя
│   │   ├── default.nix           # Пакеты, XDG, переменные
│   │   ├── programs.nix          # Импорты программ
│   │   ├── services.nix          # Пользовательские сервисы
│   │   └── secrets.nix           # sops-nix секреты
│   ├── programs/                 # Программы (по одному модулю на каждую)
│   │   ├── fish/                 # Оболочка Fish + Starship
│   │   ├── ghostty/              # Терминал Ghostty (Rosé Pine)
│   │   ├── git/                  # Git + GitHub CLI + GPG
│   │   ├── neovim/               # AstroNvim + LSP серверы
│   │   ├── zellij/               # Мультиплексор (Alt-keybinds)
│   │   ├── crush/                # Локальный LLM (Ollama)
│   │   ├── discord/              # Equicord через nixcord + прокси
│   │   ├── sing-box/             # VLESS прокси (конфиг из sops)
│   │   ├── dms/                  # DMS виджеты + погода
│   │   ├── vivaldi/              # Браузер по умолчанию
│   │   └── ...                   # intellij, obs, chrome, yazi, fuzzle, vscode, zed
│   ├── scripts/mikoshi.nix       # Скрипт пересборки
│   ├── themes/                   # GTK тема + Rosé Pine цвета
│   └── wm/niri/                  # Niri WM
│       ├── default.nix           # Пакеты, env-переменные Wayland
│       └── config/*.kdl          # Конфигурация Niri (7 файлов)
├── secrets/secrets.yaml          # Зашифрованные секреты (sops + age)
└── .sops.yaml                    # Ключи шифрования
```

## Ключевые решения

| Что | Выбор | Почему |
|-----|-------|--------|
| WM | Niri | Скроллинг-тайлинг, нативный Wayland |
| Оболочка | Fish | Автодополнение из коробки, аббревиатуры |
| Терминал | Ghostty | GPU-ускорение, простая конфигурация |
| Тема | Rosé Pine | Единая палитра для терминала, Niri, Neovim |
| Редактор | Neovim (AstroNvim) | LSP для PHP, JS, Python, Java, Nix |
| Секреты | sops-nix + age | SSH ключи, GPG, GitHub токен, sing-box конфиг |
| Прокси | sing-box (VLESS) | Обход блокировок; nix-daemon, Claude, Discord через прокси |
| Discord | Equicord (nixcord) | Больше плагинов, запуск через прокси |
| GPU | AMD (amdgpu) | Mesa + AMDVLK + VA-API |
| DNS | 8.8.8.8 + 1.1.1.1 | Стабильные DNS, NM не перезаписывает resolv.conf |

## Прокси

sing-box запускается как systemd user-сервис на `127.0.0.1:1080` (SOCKS5 + HTTP).

Через прокси работают:
- `nix-daemon` — скачивание пакетов
- `claude` / `claude-node` — обёртки с proxy env
- Equicord — desktop entry переопределён
- Postman — desktop entry переопределён

Конфигурация sing-box (сервер, UUID, ключи) хранится в sops секретах.

## Секреты (sops-nix)

```bash
# Первоначальная настройка
mkdir -p ~/.config/sops/age
age-keygen -o ~/.config/sops/age/keys.txt
# Вставить public key в .sops.yaml

# Редактирование секретов
sops secrets/secrets.yaml
```

Секреты:
- `ssh_private_key` — SSH ключ (~/.ssh/id_ed25519)
- `gpg_private_key` — GPG ключ (импорт в keyring при активации)
- `github_token` — токен для `gh auth login`
- `singbox_config` — полный JSON конфиг sing-box

## LSP серверы (Neovim)

Установлены через Nix (не Mason):
- **Nix**: nil, nixd, nixfmt, statix, deadnix
- **PHP**: phpactor
- **JS/TS**: typescript-language-server, prettierd, eslint
- **Python**: pyright, ruff
- **Java**: jdt-language-server
- **Lua**: lua-language-server, stylua

## Настройка Niri

KDL-файлы в `home/wm/niri/config/`:

| Файл | Описание |
|------|----------|
| `config.kdl` | Главный файл (импортирует остальные) |
| `input.kdl` | Клавиатура (US/RU), мышь |
| `keybindings.kdl` | Горячие клавиши (Mod=Super) |
| `layout.kdl` | Тайлинг, цвета фокуса (Rosé Pine) |
| `outputs.kdl` | Мониторы |
| `workspaces.kdl` | Рабочие пространства |
| `rules.kdl` | Правила окон |

Основные хоткеи:
- `Mod+Return` — Ghostty
- `Mod+D` — DMS лаунчер
- `Mod+B` — Vivaldi
- `Mod+Q` — Закрыть окно
- `Mod+H/J/K/L` — Навигация (vim-style)
- `Mod+1-9` — Рабочие пространства

## Добавление программы

```bash
mkdir -p home/programs/my-app
```

```nix
# home/programs/my-app/my-app.nix
{ pkgs, ... }: {
  home.packages = [ pkgs.my-app ];
}
```

Добавить импорт в `home/shared/programs.nix`.

## Добавление машины

1. `mkdir -p system/machine/new-host`
2. Создать `default.nix` с `networking.hostName`
3. `nixos-generate-config --show-hardware-config > system/machine/new-host/hardware-configuration.nix`
4. Добавить имя в `hosts` в `outputs/os.nix`

## Решение проблем

```bash
# Проверить статус Niri
systemctl status greetd
journalctl --user -u niri -e

# Проверить DMS
systemctl --user status dms.service
systemctl --user restart dms.service

# Проверить sing-box
systemctl --user status sing-box
singbox-connections

# Если home-manager не найден
nix profile install nixpkgs#home-manager
```

---

Основано на [infktd/asthenia](https://github.com/infktd/asthenia).
