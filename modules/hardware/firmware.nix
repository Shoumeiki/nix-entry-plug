_: {
  # ---------------------------------------------------------------------------
  # Firmware update service.
  #
  # `fwupd` lets you check for and apply firmware updates the vendors
  # publish to the Linux Vendor Firmware Service:
  #   `fwupdmgr refresh`        — pull the latest metadata
  #   `fwupdmgr get-devices`    — see what hardware is known to LVFS
  #   `fwupdmgr update`         — apply any updates
  #
  # Covers Samsung / WD / SK Hynix NVMe firmware, motherboard UEFI
  # capsules from MSI / ASUS / Gigabyte, and a long list of peripherals.
  # ---------------------------------------------------------------------------

  services.fwupd.enable = true;
}
