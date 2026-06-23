_: {
  # Covers bare-metal (nvme, xhci_pci, ahci) and QEMU/KVM (virtio*).
  # Refine with `nixos-generate-config` output during install if anything's missing.
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
