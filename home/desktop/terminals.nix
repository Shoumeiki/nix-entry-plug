_: {
  # foot is the default $terminal in Hyprland. kitty is kept for tasks needing
  # its extra features (image protocol, ligatures, kittens).

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
