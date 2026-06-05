{ pkgs, ... }:
{
  catppuccin = {
    enable = true;
    flavor = "mocha";
    accent = "mauve";
  };

  gtk = {
    enable = true;
    font = {
      name = "Inter";
      size = 11;
    };
    iconTheme = {
      package = pkgs.papirus-icon-theme;
      name = "Papirus-Dark";
    };
    gtk3.extraConfig.gtk-application-prefer-dark-theme = 1;
    gtk4.extraConfig.gtk-application-prefer-dark-theme = 1;
  };

  qt = {
    enable = true;
    platformTheme.name = "kvantum";
    style.name = "kvantum";
  };

  fonts.fontconfig = {
    enable = true;
    defaultFonts = {
      monospace = [ "JetBrainsMono Nerd Font" ];
      sansSerif = [ "Inter" ];
      serif = [ "Merriweather" ];
    };
  };

  home.packages = with pkgs; [
    papirus-icon-theme
    nwg-look            # GTK theme configurator (GUI)
    qt5ct
    qt6ct
    kdePackages.qtstyleplugin-kvantum
  ];
}
