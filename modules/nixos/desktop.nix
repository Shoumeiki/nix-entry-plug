{ pkgs, ... }:
{
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    # Explicitly route portals to avoid ambiguity warnings when multiple backends
    # are installed (hyprland portal is added automatically by programs.hyprland).
    config = {
      "Hyprland" = {
        default = [ "hyprland" "gtk" ];
      };
      common = {
        default = [ "gtk" ];
      };
    };
  };

  services.pipewire = {
    enable = true;
    pulse.enable = true;
    wireplumber.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
  };
  security.rtkit.enable = true;

  security.polkit.enable = true;

  fonts = {
    packages = with pkgs; [
      nerd-fonts.jetbrains-mono
      merriweather
      inter
    ];
    fontconfig.defaultFonts = {
      monospace = [ "JetBrainsMono Nerd Font" ];
      sansSerif = [ "Inter" ];
      serif = [ "Merriweather" ];
    };
  };

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";        # Electron apps use Wayland
    MOZ_ENABLE_WAYLAND = "1";    # Firefox/LibreWolf
    SDL_VIDEODRIVER = "wayland";
    QT_QPA_PLATFORM = "wayland";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    GDK_BACKEND = "wayland,x11"; # GTK fallback
  };

  environment.systemPackages = with pkgs; [
    waybar
    rofi    # rofi-wayland is depreciated
    mako

    hyprlock
    hypridle
    grimblast
    wl-clipboard
    cliphist
    hyprpaper

    networkmanagerapplet
    polkit_gnome
    xdg-utils
    pavucontrol
  ];
}
