{ pkgs, ... }:
{
  # gvfs: network shares, MTP, trash. tumbler: thumbnail generation.
  programs.thunar = {
    enable = true;
    plugins = with pkgs; [
      thunar-archive-plugin # right-click → create archive
      thunar-volman # auto-mount removable devices
      thunar-media-tags-plugin # ID3 tag editing
    ];
  };

  services.gvfs.enable = true;
  services.tumbler.enable = true;
}
