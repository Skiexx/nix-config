{ config, pkgs, ... }:

{
  programs.bash = {
    enable = true;
    shellAliases = {
      nr = "sudo nixos-rebuild switch --flake ~/nix-config#nixos";
      hm = "home-manager switch --flake ~/nix-config#skiexx";
      update = "echo ''; \
                echo '🔄 Обновление флейка...'; \
                echo '--------------------------------------'; \
                nix flake update; \
                \
                echo ''; \
                echo '🚀 Применение системных изменений...';  \ 
                echo '--------------------------------------'; \
                nr; \
                \
                echo ''; \
                echo '🏠 Применение пользовательских изменений...'; \
                echo '--------------------------------------'; \
                hm; \
                \
                echo ''; \
                echo '✅ Обновление завершено!'; \
                echo '======================================'; \
                echo ''";
    };
  };
}
