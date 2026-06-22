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
  # Portal-preference is split deliberately:
  #
  #   - `common.default = ["gtk"]` — fallback for ANY session that isn't
  #     Hyprland (greetd/cage, TTY-launched GTK tools, future GNOME/KDE
  #     specialisations, etc). The Hyprland portal segfaults during
  #     shutdown when loaded in a session without a running Hyprland —
  #     it tries to clean up Wayland output proxies against a connection
  #     that doesn't exist (`wl_map_insert_at` in libwayland-client).
  #     Restricting it to actual Hyprland sessions prevents the crash.
  #
  #   - `hyprland.default = ["hyprland" "gtk"]` — when XDG_CURRENT_DESKTOP
  #     is Hyprland (i.e. the real session), prefer the Hyprland portal
  #     for screencast / screenshot / screen share, fall through to GTK
  #     for file chooser etc.
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
      common.default = [ "gtk" ];
      hyprland.default = [
        "hyprland"
        "gtk"
      ];
    };
  };
}
