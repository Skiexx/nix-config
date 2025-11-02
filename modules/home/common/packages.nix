{ pkgs, ... }:

{
  home.packages = with pkgs; [
    htop
    tree
    curl
    wget
  ];
}
