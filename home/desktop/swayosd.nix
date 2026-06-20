_: {
  # ---------------------------------------------------------------------------
  # swayosd: on-screen indicator for volume / brightness / caps-lock.
  #
  # Hyprland's media-key binds (home/desktop/hyprland.nix) route through
  # `swayosd-client` so each volume / mute / mic press surfaces a
  # centered slider instead of silently changing the level. Without it,
  # the only feedback is the audio itself getting louder/quieter.
  #
  # home-manager's `services.swayosd` runs the swayosd-server as a user
  # systemd unit on the Wayland session and installs the swayosd-client
  # binary used by the Hyprland keybinds.
  # ---------------------------------------------------------------------------

  services.swayosd.enable = true;
}
