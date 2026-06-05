{ pkgs, ... }:
{
  # -------------------------------------------------------------------------
  # Neovim (configured as a Home Manager program)
  # LazyVim is bootstrapped separately on first login:
  #   git clone https://github.com/LazyVim/starter ~/.config/nvim
  # After that, LazyVim handles plugin installation via its own bootstrap.
  # extraPackages below make LSP servers and formatters available in PATH.
  # -------------------------------------------------------------------------
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;

    extraPackages = with pkgs; [
      # Lua (LazyVim itself + config files)
      lua-language-server
      stylua

      # Shell
      bash-language-server
      shfmt

      # Nix
      nil
      nixfmt-rfc-style

      # Required by Telescope / snacks.nvim pickers
      ripgrep
      fd
    ];
  };

  # -------------------------------------------------------------------------
  # Zed editor (GUI, secondary editor)
  # -------------------------------------------------------------------------
  programs.zed-editor = {
    enable = true;
    extensions = [ "nix" "toml" "fish" "env" ];

    userSettings = {
      theme = {
        mode = "dark";
        dark = "Catppuccin Mocha";
        light = "Catppuccin Latte";
      };
      ui_font_family = "Inter";
      ui_font_size = 14;
      buffer_font_family = "JetBrainsMono Nerd Font";
      buffer_font_size = 14;
      buffer_font_features = { calt = true; };  # ligatures
      vim_mode = false;
      format_on_save = "on";
      autosave = "on_focus_change";
      tab_size = 2;
      soft_wrap = "editor_width";
      show_whitespaces = "selection";
    };
  };
}
