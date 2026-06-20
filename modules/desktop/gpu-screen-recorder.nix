{ pkgs, ... }:
{
  # ---------------------------------------------------------------------------
  # GPU Screen Recorder.
  #
  # Hardware-accelerated screen recorder/streamer. Uses the GPU's video
  # encoder (VAAPI on AMD) directly, so it sits at near-zero CPU even at
  # 4K144. Native KMS + PipeWire capture path on Wayland — no X11 fallback.
  #
  # `programs.gpu-screen-recorder.enable` installs the CLI and sets up a
  # setcap wrapper for `gsr-kms-server` so KMS capture doesn't prompt for
  # sudo on every recording.
  #
  # The GTK GUI lives in environment.systemPackages so the wrappers it
  # depends on (gpu-screen-recorder + gsr-kms-server) resolve via the
  # system PATH rather than a separate user-level closure.
  # ---------------------------------------------------------------------------

  programs.gpu-screen-recorder.enable = true;

  environment.systemPackages = [ pkgs.gpu-screen-recorder-gtk ];
}
