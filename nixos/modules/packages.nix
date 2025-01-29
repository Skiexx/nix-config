{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    vim
    wget
    curl
    git
    htop
    unzip
    zip
    neofetch
    tmux
    home-manager
    tree
  ];
}
