_: {
  # ---------------------------------------------------------------------------
  # Hyprland: enable the compositor at the system level.
  #
  # `programs.hyprland.enable` does the system-side work:
  #   - installs the Hyprland binary
  #   - registers a Wayland session entry (so it appears in greetd /
  #     ReGreet's session list)
  #   - pulls in xdg-desktop-portal-hyprland (extended in xdg-portal.nix)
  #   - enables polkit integration
  #
  # XWayland is on by default. Per-user Hyprland config (keybinds,
  # monitors, animations, hyprpaper, hyprlock, hypridle) lives in
  # home-manager (Phase 5).
  # ---------------------------------------------------------------------------

  programs.hyprland.enable = true;
}
