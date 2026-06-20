{ pkgs, ... }:
{
  # ---------------------------------------------------------------------------
  # Per-user audio bits.
  #
  # PipeWire / WirePlumber are configured at the system level
  # (modules/hardware/audio.nix). What lives here is the user-facing
  # control surface: mixer GUI for switching between the UMC22 / MR4 /
  # bluetooth sinks, EQ utility for the headphone chain.
  #
  # Default-sink routing is per-device runtime state — set once via
  # pavucontrol or `wpctl set-default <id>` and WirePlumber remembers it.
  # No declarative config needed.
  # ---------------------------------------------------------------------------

  home.packages = with pkgs; [
    pavucontrol # PipeWire mixer (uses the legacy name)
    easyeffects # EQ / effects per-app or per-sink
  ];
}
