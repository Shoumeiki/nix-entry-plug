_: {
  # Stylix sets the cursor package/name/size. These flags ensure it applies
  # consistently across native Wayland (hyprcursor), GTK, and XWayland apps.

  home.pointerCursor = {
    hyprcursor.enable = true;
    gtk.enable = true;
    x11.enable = true;
  };
}
