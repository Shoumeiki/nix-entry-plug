{ pkgs, ... }:
{
  # ---------------------------------------------------------------------------
  # rofi: app launcher / dmenu replacement.
  #
  # `rofi-wayland` is the Wayland fork; the upstream `rofi` is X11-only.
  # Stylix themes via stylix.targets.rofi.
  # ---------------------------------------------------------------------------

  programs.rofi = {
    enable = true;
    package = pkgs.rofi-wayland;

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
