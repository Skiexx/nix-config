{ config, pkgs, lib, ... }:

{
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    extraPackages = with pkgs; [
      gcc
      ripgrep
      fd
      tree-sitter
      nodejs
      pnpm
      python3
      python311Packages.pynvim
      lua-language-server
      stylua
      fzf
      bat
      lazygit
      jq
    ];
  };

  home.file = {
    ".config/nvim" = { 
      source = pkgs.fetchFromGitHub {
        owner = "Skiexx";
        repo = "astronvim_config";
        rev = "main";
        sha256 = "sha256-Fu0nUmwl5140RcB6DTAHdLi0W0Z9n/93cM9NRG7IgOM=";
      };
      recursive = true;
    };
  };
}
