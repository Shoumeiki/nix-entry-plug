{ pkgs, ... }:
{
  # VAAPI-accelerated recorder; setcap wrapper allows KMS capture without sudo.
  # GTK GUI is in systemPackages so it resolves the CLI wrappers via system PATH.
  programs.gpu-screen-recorder.enable = true;

  environment.systemPackages = [ pkgs.gpu-screen-recorder-gtk ];
}
