_: {
  # ---------------------------------------------------------------------------
  # SSD / NVMe maintenance.
  #
  #   fstrim — weekly TRIM of every discard-capable mounted filesystem.
  #            Preferred over the `discard` mount option (continuous trim)
  #            for write performance.
  #   smartd — daemon that monitors SMART attributes and shouts in the
  #            log (and via wall) when a drive looks like it's failing.
  # ---------------------------------------------------------------------------

  services = {
    fstrim.enable = true;

    smartd = {
      enable = true;
      autodetect = true;
      notifications.wall.enable = true;
    };
  };
}
