_: {
  # ---------------------------------------------------------------------------
  # rofi: app launcher / dmenu replacement.
  #
  # Stylix themes the visuals via stylix.targets.rofi. Behaviour knobs live
  # here.
  # ---------------------------------------------------------------------------

  programs.rofi = {
    enable = true;

    extraConfig = {
      modi = "drun,run,window,filebrowser";
      show-icons = true;
      drun-display-format = "{name}";
      sidebar-mode = true;
      kb-cancel = "Escape,Super+d";
    };
  };
}
