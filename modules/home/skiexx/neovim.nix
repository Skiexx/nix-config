{ pkgs, lib, inputs, config, ... }:


let
  basePackages = with pkgs; [
    tree-sitter wl-clipboard git fd fzf unzip gcc gnumake luajitPackages.luarocks
    nodejs
    python3
  ];

  optionalPackages = with pkgs; [
    ripgrep lazygit gdu bottom
  ];

  rustPackages = lib.optionals config.programs.neovim.languageSupport.rust.enable (with pkgs; [
    rust-analyzer rustfmt
  ]);

  javaPackages = lib.optionals config.programs.neovim.languageSupport.java.enable (with pkgs; [
    jdtls
  ]);

  phpPackages = lib.optionals config.programs.neovim.languageSupport.php.enable (with pkgs; [
    nodePackages.intelephense
  ]);

  jsPackages = lib.optionals config.programs.neovim.languageSupport.js.enable (with pkgs; [
    nodePackages.typescript-language-server nodePackages.prettier
  ]);
{
  options.programs.neovim.languageSupport = {
    rust.enable = lib.mkOption { type = lib.types.bool; default = false; description = "Enable Rust if installed."; };
    java.enable = lib.mkOption { type = lib.types.bool; default = false; description = "Enable Java if installed."; };
    php.enable = lib.mkOption { type = lib.types.bool; default = false; description = "Enable PHP if installed."; };
    js.enable = lib.mkOption { type = lib.types.bool; default = false; description = "Enable JS/TS if installed."; };
  };

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    defaultEditor = true;
    extraConfig = ''
      set number
      set relativenumber
    '';
    extraPackages = with pkgs; [
      basePackages
      optionalPackages
      rustPackages
      javaPackages
      phpPackages
      jsPackages
    ];
  };

  home.file.".config/nvim" = {
    source = inputs.astronvim;
    recursive = true;
  };

  home.activation.setupAstroNvim = lib.hm.dag.entryAfter ["writeBoundary"] ''
    if [ ! -d ~/.local/share/nvim/lazy/lazy.nvim ]; then
      ${pkgs.neovim}/bin/nvim --headless "+Lazy! sync" +qa
    fi
  '';
}
