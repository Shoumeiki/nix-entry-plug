_: {
  # Stylix themes visuals via stylix.targets.rofi. This file sets behaviour only.

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
