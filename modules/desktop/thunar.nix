{ pkgs, ... }:
{
  # ---------------------------------------------------------------------------
  # Thunar: GTK file manager.
  #
  # `programs.thunar` is system-level (registers MIME associations, the
  # `Open with` integration, and the thunar-daemon service); per-user
  # settings (bookmarks, columns) live in home-manager state and are
  # configured interactively.
  #
  # gvfs handles mounts (network shares, MTP devices, trash). tumbler
  # generates thumbnails for the icon view.
  # ---------------------------------------------------------------------------

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
