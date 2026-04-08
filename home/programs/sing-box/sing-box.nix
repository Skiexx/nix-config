# Конфигурация прокси sing-box (секреты через sops, systemd-сервис)
{
  pkgs,
  lib,
  config,
  ...
}: let
  # sing-box config is generated from sops secrets at activation time
  singboxConfigScript = pkgs.writeShellScript "generate-singbox-config" ''
    SECRETS_DIR="${config.sops.secrets.singbox_config.path}"
    CONFIG_DIR="$HOME/.config/sing-box"
    mkdir -p "$CONFIG_DIR"
    cp "$SECRETS_DIR" "$CONFIG_DIR/config.json"
  '';
in {
  home.packages = with pkgs; [
    sing-box

    (writeShellScriptBin "singbox-start" ''
      CONFIG="$HOME/.config/sing-box/config.json"
      if [ ! -f "$CONFIG" ]; then
        echo "Error: sing-box config not found. Run 'home-manager switch' first."
        exit 1
      fi
      exec ${sing-box}/bin/sing-box run -c "$CONFIG"
    '')

    (writeShellScriptBin "singbox-connections" ''
      curl -s http://127.0.0.1:9090/connections | ${jq}/bin/jq '.connections[] | {host: .metadata.host, dest: .metadata.destinationIP, chain: .chains, download: .download, upload: .upload}'
    '')
  ];

  # Generate config from secrets on activation
  home.activation.generateSingboxConfig = lib.hm.dag.entryAfter [ "writeBoundary" "sops-nix" ] ''
    if [ -f "${config.sops.secrets.singbox_config.path}" ]; then
      CONFIG_DIR="$HOME/.config/sing-box"
      mkdir -p "$CONFIG_DIR"
      cp "${config.sops.secrets.singbox_config.path}" "$CONFIG_DIR/config.json"
      chmod 600 "$CONFIG_DIR/config.json"
    fi
  '';

  # Systemd user service
  systemd.user.services.sing-box = {
    Unit = {
      Description = "sing-box proxy service";
      After = ["network.target"];
    };
    Service = {
      Type = "simple";
      ExecStart = "${pkgs.sing-box}/bin/sing-box run -c %h/.config/sing-box/config.json";
      Restart = "on-failure";
      RestartSec = 5;
    };
    Install = {
      WantedBy = ["default.target"];
    };
  };
}
