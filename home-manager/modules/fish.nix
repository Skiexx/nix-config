{ config, pkgs, lib, ... }:

{
  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      starship init fish | source
    '';
    plugins = with pkgs.fishPlugins; [
      bass
      z
      done
      plugin-git
      fish-you-should-use
      puffer
      sponge
      colored-man-pages
      pisces
      fzf-fish
      bang-bang
    ];
  };

  programs.starship = {
    enable = true;
  };
  
  home.packages = with pkgs; [
    fzf
    fd
    bat
    eza
  ];
}
