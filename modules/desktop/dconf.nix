_: {
  # ---------------------------------------------------------------------------
  # dconf: GSettings backend used by GTK / GNOME-family apps.
  #
  # Needed even on Hyprland because Thunar, file pickers, GTK theming
  # (including Stylix's GTK output), Nautilus-style apps, and many
  # Flatpak-targeting apps read settings from dconf at runtime.
  # ---------------------------------------------------------------------------

  programs.dconf.enable = true;
}
