_: {
  # Assumes a Wayland/Hyprland session. Don't import from headless host entrypoints.
  imports = [
    ./apps.nix
    ./audio.nix
    ./browsers.nix
    ./cursor.nix
    ./fun.nix
    ./hyprland.nix
    ./hyprshade.nix
    ./mako.nix
    ./rofi.nix
    ./swayosd.nix
    ./terminals.nix
    ./waybar.nix
  ];
}
