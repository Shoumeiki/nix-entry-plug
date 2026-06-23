_: {
  # Needed on Hyprland for GTK theming (Stylix), Thunar, file pickers, and
  # Electron/Flatpak apps that read GSettings from dconf at runtime.
  programs.dconf.enable = true;
}
