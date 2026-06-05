{ pkgs, ... }:
{
  # -------------------------------------------------------------------------
  # Hyprland compositor
  # -------------------------------------------------------------------------
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # -------------------------------------------------------------------------
  # Display manager (SDDM, Wayland mode)
  # -------------------------------------------------------------------------
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };

  # -------------------------------------------------------------------------
  # XDG portals
  # Required for screen sharing, file pickers, and Flatpak (if added later).
  # xdg-desktop-portal-hyprland is pulled in by programs.hyprland.
  # xdg-desktop-portal-gtk provides fallback portal for GTK apps.
  # -------------------------------------------------------------------------
  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  # -------------------------------------------------------------------------
  # Audio: PipeWire
  # -------------------------------------------------------------------------
  services.pipewire = {
    enable = true;
    pulse.enable = true;
    wireplumber.enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
  };
  security.rtkit.enable = true;

  # -------------------------------------------------------------------------
  # Polkit (required for privileged GUI operations)
  # -------------------------------------------------------------------------
  security.polkit.enable = true;

  # -------------------------------------------------------------------------
  # System fonts
  # Individual app font configuration is done in modules/home/theming.nix.
  # -------------------------------------------------------------------------
  fonts = {
    packages = with pkgs; [
      nerd-fonts.jetbrains-mono
      merriweather
      atkinson-hyperlegible
    ];
    fontconfig.defaultFonts = {
      monospace = [ "JetBrainsMono Nerd Font" ];
      sansSerif = [ "Atkinson Hyperlegible" ];
      serif = [ "Merriweather" ];
    };
  };

  # -------------------------------------------------------------------------
  # Wayland environment variables (system-wide)
  # -------------------------------------------------------------------------
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";        # Electron apps use Wayland
    MOZ_ENABLE_WAYLAND = "1";    # Firefox/LibreWolf
    SDL_VIDEODRIVER = "wayland";
    QT_QPA_PLATFORM = "wayland";
    QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
    GDK_BACKEND = "wayland,x11"; # GTK fallback
  };

  # -------------------------------------------------------------------------
  # Desktop packages (system-level; HM-managed apps go in modules/home/)
  # -------------------------------------------------------------------------
  environment.systemPackages = with pkgs; [
    waybar
    rofi-wayland
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
