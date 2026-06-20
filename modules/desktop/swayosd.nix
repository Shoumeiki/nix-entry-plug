_: {
  # ---------------------------------------------------------------------------
  # swayosd: on-screen indicator for volume / brightness / caps-lock.
  #
  # Hyprland's media-key binds (home/desktop/hyprland.nix) route through
  # `swayosd-client` so each volume / mute / mic press surfaces a
  # centered slider instead of silently changing the level. Without it,
  # the only feedback is the audio itself getting louder/quieter.
  #
  # The NixOS module sets up the system service that watches for input
  # events and renders the OSD layer-shell window.
  # ---------------------------------------------------------------------------

  services.swayosd.enable = true;
}
