_: {
  # ---------------------------------------------------------------------------
  # rofi: app launcher / dmenu replacement.
  #
  # `pkgs.rofi` is now the unified package (Wayland support was merged
  # upstream; the old `rofi-wayland` fork is an alias / has been retired).
  # Stylix themes via stylix.targets.rofi.
  # ---------------------------------------------------------------------------

  programs.rofi = {
    enable = true;

    # Common knobs. Most theming is Stylix-driven; these are functional
    # behaviour, not visuals.
    extraConfig = {
      modi = "drun,run,window,filebrowser";
      show-icons = true;
      drun-display-format = "{name}";
      sidebar-mode = true;
      kb-cancel = "Escape,Super+d";
    };
  };
}
