{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  customFonts = with (pkgs.nerd-fonts); [
    jetbrains-mono
    iosevka
    fira-code
  ];

  myfonts = pkgs.callPackage fonts/default.nix {inherit pkgs;};
in {
  # === ЗАГРУЗКА ===
  boot.kernelPackages = pkgs.linuxPackages_zen; # Zen kernel — оптимизирован для десктопа и игр
  boot.kernelParams = [
    "processor.max_cstate=1"
  ];
  boot.kernel.sysctl = {
    "fs.inotify.max_user_watches" = 524288;
    "fs.inotify.max_user_instances" = 524288;
  };
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";
  boot.loader.systemd-boot.enable = true;

  # === СИСТЕМНЫЕ ПАКЕТЫ ===
  environment.systemPackages = with pkgs; [
    curl
    devenv
    dive
    docker
    docker-compose
    git
    home-manager
    pcscliteWithPolkit
    podman-tui
    vim
    wget
    mesa
    vulkan-tools
    vulkan-loader
    vulkan-validation-layers
    libva-utils
    lact
    pciutils
    usbutils
    duf
  ];

  # === ШРИФТЫ ===
  fonts.packages = with pkgs;
    [
      font-awesome
    ]
    ++ customFonts;

  # === ЛОКАЛИЗАЦИЯ ===
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # === СЕТЬ ===
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [];
    allowedUDPPorts = [];
  };
  networking.nameservers = [ "8.8.8.8" "1.1.1.1" ];
  networking.networkmanager = {
    enable = true;
    dns = "systemd-resolved"; # Используем systemd-resolved для управления DNS
  };

  # systemd-resolved — управляет DNS с поддержкой fallback
  # Tailscale добавляет свой DNS автоматически, наши 8.8.8.8/1.1.1.1 будут fallback
  services.resolved = {
    enable = true;
    fallbackDns = [ "8.8.8.8" "1.1.1.1" ];
    dnsovertls = "opportunistic"; # DNS-over-TLS когда поддерживается
  };

  # === НАСТРОЙКИ NIX ===
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };
  nix.package = pkgs.nixVersions.latest;
  nix.settings = {
    auto-optimise-store = true;
    experimental-features = ["nix-command" "flakes"];
    substituters = [
      "https://cache.nixos.org"
      "https://nix-community.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
    trusted-users = ["root" "@wheel"];
  };

  # === ПРОГРАММЫ ===
  programs.fish.enable = true;
  programs.nix-ld = {
    enable = true;
    libraries = pkgs.steam-run.args.multiPkgs pkgs;
  };

  # === БЕЗОПАСНОСТЬ ===
  security.rtkit.enable = true;

  # === СЛУЖБЫ ===
  services.avahi.enable = true;
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = true;
      PermitRootLogin = "no";
    };
  };
  services.pcscd.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    extraConfig.pipewire = {
      "10-airplay" = {
        "context.modules" = [
          {
            name = "libpipewire-module-raop-discover";
          }
        ];
      };
    };
    pulse.enable = true;
    raopOpenFirewall = true;
  };
  services.pulseaudio.enable = false;
  services.tailscale.enable = true;

  # === NIX-DAEMON ПРОКСИ ===
  # nix-daemon скачивает пакеты через прокси sing-box (SOCKS5 на 127.0.0.1:1080)
  # Если sing-box не запущен — скачивание будет идти напрямую (soft fail)
  systemd.services.nix-daemon.environment = {
    http_proxy = "socks5://127.0.0.1:1080";
    https_proxy = "socks5://127.0.0.1:1080";
    all_proxy = "socks5://127.0.0.1:1080";
    no_proxy = "localhost,127.0.0.1,::1";
  };

  # === СЕКРЕТЫ (SOPS) ===
  sops = {
    defaultSopsFile = ../secrets/secrets.yaml;
    age.keyFile = "/home/skiexx/.config/sops/age/keys.txt";
  };

  # === СИСТЕМА ===
  system.stateVersion = "24.11";

  # === ЧАСОВОЙ ПОЯС ===
  time.timeZone = "Asia/Tomsk";

  # === ПОЛЬЗОВАТЕЛИ ===
  users.users.skiexx = {
    description = "skiexx";
    extraGroups = ["networkmanager" "wheel" "video" "render" "docker"];
    isNormalUser = true;
    shell = pkgs.fish;
  };

  # === ВИРТУАЛИЗАЦИЯ ===
  virtualisation.containers.enable = true;
  virtualisation.podman = {
    defaultNetwork.settings.dns_enabled = true;
    dockerCompat = true;
    dockerSocket.enable = true;
    enable = true;
  };
}
