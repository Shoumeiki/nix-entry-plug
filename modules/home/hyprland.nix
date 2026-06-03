{ ... }:
{
  wayland.windowManager.hyprland = {
    enable = true;
    settings = {
      monitor = [
        "DP-1,3840x2160@120,0x0,1"
        "HDMI-A-1,3840x2560@60,3840x0,1"
      ];

      exec-once = [
        "hyprctl output create headless"
        "waybar"
        "mako"
      ];

      decoration = {
        rounding = 8;
        blur = {
          enabled = true;
          size = 6;
          passes = 2;
        };
      };
    };
  };
}
