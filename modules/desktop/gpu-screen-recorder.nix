_: {
  # VAAPI-accelerated recorder; setcap wrapper allows KMS capture without sudo.
  # The GTK GUI lives in home/desktop/apps.nix.
  programs.gpu-screen-recorder.enable = true;
}
