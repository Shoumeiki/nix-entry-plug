{ pkgs, ... }:
{
  # PipeWire/WirePlumber are system-level (modules/hardware/audio.nix).
  # This is just the user-facing control surface.

  home.packages = with pkgs; [
    pavucontrol # PipeWire mixer (uses the legacy name)
    easyeffects # EQ / effects per-app or per-sink
  ];
}
