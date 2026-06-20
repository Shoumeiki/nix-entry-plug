_: {
  # ---------------------------------------------------------------------------
  # Hardware tweaks for unit-01.
  #
  # initrd modules cover both the real AM5 box (ahci, xhci_pci, sd_mod,
  # nvme) and a QEMU/KVM guest (virtio*) so the same config boots in both.
  # Refine with the output of `nixos-generate-config` during the install
  # if anything's missing.
  # ---------------------------------------------------------------------------

  boot.initrd.availableKernelModules = [
    # VM
    "virtio_pci"
    "virtio_blk"
    "virtio_scsi"
    "virtio_net"
    # Bare metal
    "ahci"
    "nvme"
    "xhci_pci"
    "usbhid"
    "sd_mod"
    "sr_mod"
  ];
}
