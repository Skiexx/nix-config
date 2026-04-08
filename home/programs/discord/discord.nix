# =============================================================================
# DISCORD — Equibop через nixcord с HTTP прокси из sops
# =============================================================================
{
  inputs,
  config,
  pkgs,
  ...
}: {
  imports = [
    inputs.nixcord.homeModules.nixcord
  ];

  programs.nixcord = {
    enable = true;
    discord.enable = false;
    equibop.enable = true;
  };

  # Обёртка: читает прокси из sops-секрета
  home.packages = with pkgs; [
    (writeShellScriptBin "equibop-proxy" ''
      PROXY_FILE="${config.sops.secrets.discord_proxy.path}"
      if [ -f "$PROXY_FILE" ]; then
        PROXY=$(cat "$PROXY_FILE")
        HTTP_PROXY="$PROXY" \
        HTTPS_PROXY="$PROXY" \
        ALL_PROXY="$PROXY" \
        exec equibop "$@"
      else
        echo "Прокси не найден: $PROXY_FILE"
        echo "Запуск без прокси..."
        exec equibop "$@"
      fi
    '')
  ];

  # Переопределяем .desktop файл equibop
  xdg.desktopEntries.equibop = {
    name = "Equicord";
    comment = "Equicord — Discord с прокси";
    exec = "equibop-proxy %U";
    icon = "equibop";
    terminal = false;
    type = "Application";
    categories = [ "Network" "InstantMessaging" ];
  };
}
