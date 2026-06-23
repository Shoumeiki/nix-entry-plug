{ pkgs, ... }:
{
  # Two portal backends: xdp-hyprland (screencast/screenshot) + xdp-gtk (file picker,
  # settings, fallback). `common.default = ["gtk"]` prevents the Hyprland portal from
  # loading in non-Hyprland sessions where it segfaults on shutdown.
  xdg.portal = {
    enable = true;
    xdgOpenUsePortal = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-hyprland
      xdg-desktop-portal-gtk
    ];
    config = {
      common.default = [ "gtk" ];
      hyprland.default = [
        "hyprland"
        "gtk"
      ];
    };
  };
}
