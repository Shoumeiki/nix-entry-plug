_: {
  # ---------------------------------------------------------------------------
  # Pointer cursor.
  #
  # Stylix sets the cursor package + name + size at the home-manager level.
  # We have to flip the per-toolkit enable flags ourselves so the cursor
  # is consistent across native Wayland (hyprcursor), GTK, and XWayland
  # apps. Without these, you'll see the Bibata cursor in some windows
  # and the default Adwaita cursor in others.
  # ---------------------------------------------------------------------------

  home.pointerCursor = {
    hyprcursor.enable = true;
    gtk.enable = true;
    x11.enable = true;
  };
}
