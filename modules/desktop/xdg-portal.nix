{ pkgs, ... }:
{
  # ---------------------------------------------------------------------------
  # XDG desktop portals.
  #
  # Portals bridge sandboxed / Wayland apps to system services
  # (file picker, screenshot, screencast, settings). On Hyprland we need
  # two backends:
  #   - xdg-desktop-portal-hyprland → screenshot, screencast, screen share
  #     (pulled in automatically by programs.hyprland.enable, listed
  #     explicitly here for clarity)
  #   - xdg-desktop-portal-gtk → file chooser, settings, fallback for
  #     everything the Hyprland portal doesn't implement
  #
  # `config.common.default` makes the Hyprland portal first-preference
  # with GTK as fallback for any interface it doesn't handle (notably
  # the file chooser).
  # ---------------------------------------------------------------------------

  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-hyprland
      xdg-desktop-portal-gtk
    ];
    config = {
      common.default = [
        "hyprland"
        "gtk"
      ];
      hyprland.default = [
        "hyprland"
        "gtk"
      ];
    };
  };
}
