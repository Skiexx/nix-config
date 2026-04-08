# =============================================================================
# УПРАВЛЕНИЕ СЕКРЕТАМИ (sops-nix)
# =============================================================================
# Секреты зашифрованы в secrets/secrets.yaml (в git)
# Приватный age-ключ: ~/.config/sops/age/keys.txt (НЕ в git)
# Редактирование: sops secrets/secrets.yaml
# =============================================================================
{ config, lib, pkgs, isDarwin ? false, ... }:

let
  homeDir = "/home/skiexx";
in
{
  sops = {
    age.keyFile = "${homeDir}/.config/sops/age/keys.txt";
    defaultSopsFile = ../../secrets/secrets.yaml;

    secrets = {
      ssh_private_key = {
        path = "${homeDir}/.ssh/id_ed25519";
        mode = "0600";
      };

      gpg_private_key = {
        mode = "0600";
      };

      github_token = {
        mode = "0600";
      };

      # HTTP прокси для Discord (отдельный от sing-box)
      discord_proxy = {
        mode = "0600";
      };

      # Полный конфиг sing-box (сервер, uuid, ключи)
      singbox_config = {
        mode = "0600";
      };
    };
  };

  # Создание директории ~/.ssh
  home.file.".ssh/.keep" = {
    text = "";
    onChange = ''chmod 700 ${homeDir}/.ssh'';
  };

  # Публичный SSH-ключ
  home.file.".ssh/id_ed25519.pub" = {
    text = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEP/L8my9+pN8sYkKPsQZKNJSQDd9P9542qWTNWzAmSC skiexx@arasaka\n";
    onChange = ''chmod 644 ${homeDir}/.ssh/id_ed25519.pub'';
  };

  # Импорт GPG-ключа при активации
  home.activation.importGpgKey = lib.hm.dag.entryAfter [ "writeBoundary" "sops-nix" ] ''
    if [ -f "${config.sops.secrets.gpg_private_key.path}" ]; then
      ${pkgs.gnupg}/bin/gpg --batch --import ${config.sops.secrets.gpg_private_key.path} 2>/dev/null || true
    fi
  '';

  # Авторизация GitHub CLI по токену
  home.activation.setupGhToken = lib.hm.dag.entryAfter [ "writeBoundary" "sops-nix" ] ''
    if [ -f "${config.sops.secrets.github_token.path}" ]; then
      TOKEN=$(cat ${config.sops.secrets.github_token.path})
      mkdir -p ${homeDir}/.config/gh
      echo "$TOKEN" | ${pkgs.gh}/bin/gh auth login --with-token 2>/dev/null || true
    fi
  '';
}
