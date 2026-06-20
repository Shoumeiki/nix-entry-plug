{ pkgs, ... }:
{
  # ---------------------------------------------------------------------------
  # GPU Screen Recorder.
  #
  # Lightweight, hardware-accelerated screen recorder/streamer. Picked over
  # OBS for two reasons:
  #   1. Uses the GPU's video encoder (VAAPI / NVENC) directly, so it sits
  #      at near-zero CPU even at 4K144.
  #   2. Native KMS + PipeWire portal capture path on Wayland — works on
  #      Hyprland without an X11 fallback.
  #
  # `programs.gpu-screen-recorder.enable` does two things we care about:
  #   - installs the `gpu-screen-recorder` CLI system-wide
  #   - sets up a setcap wrapper for `gsr-kms-server` so KMS capture
  #     doesn't prompt for sudo on every recording
  #
  # The GTK GUI lives in environment.systemPackages so the wrappers it
  # depends on (gpu-screen-recorder + gsr-kms-server) resolve via the
  # system PATH rather than a separate user-level closure.
  # ---------------------------------------------------------------------------

  programs.gpu-screen-recorder.enable = true;

  environment.systemPackages = [ pkgs.gpu-screen-recorder-gtk ];
}
