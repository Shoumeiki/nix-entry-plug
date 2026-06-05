{ pkgs, ... }:
{
  # -------------------------------------------------------------------------
  # Catppuccin (applied globally to all supported HM programs)
  # The catppuccin module is imported via flake.nix sharedModules.
  # Per-program overrides can be set with e.g.:
  #   programs.foot.catppuccin.enable = false;
  # -------------------------------------------------------------------------
  catppuccin = {
    enable = true;
    flavor = "mocha";
    accent = "mauve";
  };

  # -------------------------------------------------------------------------
  # GTK theming
  # -------------------------------------------------------------------------
  gtk = {
    enable = true;
    font = {
      name = "Atkinson Hyperlegible";
      size = 11;
    };
    iconTheme = {
      package = pkgs.papirus-icon-theme;
      name = "Papirus-Dark";
    };
    gtk3.extraConfig.gtk-application-prefer-dark-theme = 1;
    gtk4.extraConfig.gtk-application-prefer-dark-theme = 1;
  };

  # -------------------------------------------------------------------------
  # Qt theming (Kvantum for consistent Qt/GTK appearance)
  # -------------------------------------------------------------------------
  qt = {
    enable = true;
    platformTheme.name = "kvantum";
    style.name = "kvantum";
  };

  # -------------------------------------------------------------------------
  # Font configuration (per-user defaults for fontconfig)
  # System defaults are also set in modules/nixos/desktop.nix.
  # -------------------------------------------------------------------------
  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      monospace = [ "JetBrainsMono Nerd Font" ];
      sansSerif = [ "Atkinson Hyperlegible" ];
      serif = [ "Merriweather" ];
    };
  };

  # -------------------------------------------------------------------------
  # Packages: theming support tools
  # -------------------------------------------------------------------------
  home.packages = with pkgs; [
    papirus-icon-theme
    nwg-look            # GTK theme configurator (GUI)
    qt5ct
    qt6ct
    kdePackages.qtstyleplugin-kvantum
  ];
}
