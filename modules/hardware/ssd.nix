_: {
  # ---------------------------------------------------------------------------
  # SSD maintenance.
  #
  # `fstrim.timer` runs weekly and TRIMs all mounted filesystems that
  # support discard. Preferred over `discard` mount option (continuous
  # trim) for write performance.
  # ---------------------------------------------------------------------------

  services.fstrim.enable = true;
}
