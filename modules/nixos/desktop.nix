{ pkgs, ... }:
{
  # Base desktop stack.
  programs.hyprland.enable = true;

  # PipeWire audio stack
  services.pipewire = {
    enable = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };

  security.rtkit.enable = true;

  environment.systemPackages = with pkgs; [
    waybar
    rofi-wayland
    mako

    hyprlock
    hypridle
    grimblast
    wl-clipboard
    cliphist
    hyprpaper

    networkmanagerapplet
  ];
}
