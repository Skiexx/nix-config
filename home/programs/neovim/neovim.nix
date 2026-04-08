{ config, pkgs, lib, ... }:

# =============================================================================
# NEOVIM + ASTRONVIM — КОНФИГУРАЦИЯ
# =============================================================================
# Устанавливает Neovim с AstroNvim и всеми LSP-серверами/форматтерами через Nix.
# AstroNvim инициализируется при первом запуске.
#
# ПЕРВЫЙ ЗАПУСК:
#   1. Склонировать шаблон: git clone --depth 1 https://github.com/AstroNvim/template ~/.config/nvim
#   2. Запустить nvim (плагины установятся автоматически)
#   3. Rosé Pine и LSP-серверы уже настроены ниже
# =============================================================================

let
  # LSP servers installed via Nix (not Mason)
  lspPackages = with pkgs; [
    # Nix
    nil                                   # Nix LSP
    nixd                                  # Alternative Nix LSP
    nixfmt                                # Nix formatter
    statix                                # Nix linter
    deadnix                               # Dead Nix code finder

    # PHP
    phpactor                              # PHP LSP

    # JavaScript / TypeScript
    typescript-language-server
    prettierd                             # Prettier daemon (faster)
    eslint

    # Python
    pyright                               # Python LSP
    ruff                                  # Python linter + formatter

    # Java
    jdt-language-server                   # Eclipse JDT LSP

    # Rust — rust-analyzer идёт через rustup

    # Lua
    lua-language-server                   # Lua LSP
    stylua                                # Lua formatter

    # General
    tree-sitter                           # Treesitter CLI
  ];

in {
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    withNodeJs = true;
    withPython3 = true;
    withRuby = false;
  };

  home.packages = lspPackages;

  # AstroNvim user configuration
  # This creates ~/.config/nvim/lua/user/ files for customization
  xdg.configFile = {
    # AstroNvim bootstrap init (auto-clones if not present)
    "nvim/lua/user/init.lua".text = ''
      -- AstroNvim User Configuration
      -- Run :AstroUpdate to update AstroNvim core
      return {
        -- Rose Pine colorscheme
        colorscheme = "rose-pine",

        -- Plugin specifications
        plugins = {
          -- Rose Pine theme
          {
            "rose-pine/neovim",
            name = "rose-pine",
            lazy = false,
            priority = 1000,
            opts = {
              variant = "main",
              dark_variant = "main",
              dim_inactive_windows = false,
              extend_background_behind_borders = true,
            },
          },
        },

        -- LSP configuration
        lsp = {
          servers = {
            "nil_ls",         -- Nix
            "nixd",           -- Nix (alternative)
            "phpactor",       -- PHP
            "ts_ls",          -- TypeScript/JavaScript
            "pyright",        -- Python
            "jdtls",          -- Java
            "rust_analyzer",  -- Rust
            "lua_ls",         -- Lua
          },
          formatting = {
            format_on_save = false,
          },
        },

        -- Polish options
        options = {
          opt = {
            relativenumber = true,
            number = true,
            spell = false,
            signcolumn = "auto",
            wrap = false,
          },
        },
      }
    '';

    # Treesitter config for all needed parsers
    "nvim/lua/user/plugins/treesitter.lua".text = ''
      return {
        "nvim-treesitter/nvim-treesitter",
        opts = {
          ensure_installed = {
            "php", "javascript", "typescript", "python", "java", "rust",
            "nix", "lua", "json", "yaml", "toml", "bash",
            "html", "css", "markdown", "markdown_inline",
            "regex", "vim", "vimdoc", "query",
          },
        },
      }
    '';

    # Conform (formatter) configuration
    "nvim/lua/user/plugins/conform.lua".text = ''
      return {
        "stevearc/conform.nvim",
        opts = {
          formatters_by_ft = {
            nix = { "nixfmt" },
            lua = { "stylua" },
            python = { "ruff_format" },
            javascript = { "prettierd" },
            typescript = { "prettierd" },
            json = { "prettierd" },
            yaml = { "prettierd" },
            html = { "prettierd" },
            css = { "prettierd" },
            rust = { "rustfmt" },
          },
        },
      }
    '';
  };
}
