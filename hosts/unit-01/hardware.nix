_: {
  # ---------------------------------------------------------------------------
  # Hardware tweaks for unit-01.
  #
  # Phase 2 stub: just the initrd modules needed to boot both QEMU/KVM
  # (virtio*) and the real AM5 box (ahci, xhci_pci, sd_mod, nvme).
  # Phase 6 pre-install replaces this with the output of
  # `nixos-generate-config` for the actual hardware.
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
