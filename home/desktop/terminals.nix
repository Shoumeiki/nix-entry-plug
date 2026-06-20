_: {
  # ---------------------------------------------------------------------------
  # Terminal emulators.
  #
  # foot is the lightweight default (faster startup, used everywhere
  # Hyprland's $terminal binding fires). kitty is the heavier feature
  # terminal (image protocol, ligatures, kittens) kept around for tasks
  # that want it.
  #
  # Stylix themes both via stylix.targets.foot / .kitty. Fonts are
  # inherited from the global Stylix font config.
  # ---------------------------------------------------------------------------

  programs = {
    foot = {
      enable = true;
      settings = {
        main = {
          pad = "8x8";
        };
        scrollback.lines = 10000;
        mouse.hide-when-typing = "yes";
      };
    };

    kitty = {
      enable = true;
      settings = {
        scrollback_lines = 10000;
        enable_audio_bell = false;
        confirm_os_window_close = 0;
        # Slight padding for visual comfort; matches foot.
        window_padding_width = 8;
      };
    };
  };
}
