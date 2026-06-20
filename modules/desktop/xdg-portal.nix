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
  #
  # `xdgOpenUsePortal` routes `xdg-open` through the portal so default-app
  # handling actually goes through xdg-mime. Fixes the "clicking a link
  # in Discord opens the wrong browser" class of bugs.
  # ---------------------------------------------------------------------------

  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
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
