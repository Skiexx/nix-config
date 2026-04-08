{ inputs, ... }:

# =============================================================================
# DMS (Dank Material Shell) — пользовательская конфигурация
# =============================================================================
# Настраивает ПОЛЬЗОВАТЕЛЬСКИЕ параметры DMS (внешний вид, поведение).
# Системный сервис DMS управляется в system/wm/niri.nix
#
# ДВУХУРОВНЕВАЯ КОНФИГУРАЦИЯ:
# - Система (system/wm/niri.nix):
#   * programs.dms-shell с systemd
#   * Создаёт и управляет dms.service
#   * Привязывает сервис к сессии niri
#
# - Пользователь (этот файл):
#   * programs.dank-material-shell (homeModule)
#   * Тема, цвета, настройки внешнего вида
#   * Пользовательские предпочтения поведения
#
# Такое разделение позволяет:
# - Системе управлять жизненным циклом сервиса (start/stop/restart)
# - Пользователю менять внешний вид (без root)
# =============================================================================

{
  imports = [
    inputs.dms.homeModules.dank-material-shell
  ];

  programs.dank-material-shell = {
    enable = true;

    settings = {
      theme = "rose-pine";
      dynamicTheming = true;
      weather = {
        enabled = true;
        location = "Tomsk";
      };
      plugins = {
        linux-wallpaper-engine.enabled = true;
        docker-manager.enabled = true;
        dank-launcher-keys.enabled = true;
      };
    };
  };
}
