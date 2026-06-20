_: {
  # ---------------------------------------------------------------------------
  # Desktop-specific home-manager modules.
  #
  # Anything in this directory assumes a Wayland session with Hyprland.
  # Headless hosts shouldn't import ./desktop/ from their user entrypoint.
  # ---------------------------------------------------------------------------

  imports = [
    ./audio.nix
    ./fun.nix
    ./hyprland.nix
    ./hyprshade.nix
    ./mako.nix
    ./rofi.nix
    ./terminals.nix
    ./waybar.nix
  ];
}
