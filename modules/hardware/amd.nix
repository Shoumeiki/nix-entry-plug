_: {
  # ---------------------------------------------------------------------------
  # AMD CPU + GPU support.
  #
  # Targets unit-01 (Ryzen 7 7800X3D + Radeon RX 7700 XT) but is host-agnostic
  # — any all-AMD machine can import this module unchanged.
  # ---------------------------------------------------------------------------

  hardware = {
    # AMD CPU microcode updates applied via initrd. Mitigates errata and
    # speculative-execution bugs without waiting for a BIOS update.
    cpu.amd.updateMicrocode = true;

    # Pull in linux-firmware blobs (GPU firmware, Wi-Fi, etc.) that aren't
    # part of the kernel proper.
    enableRedistributableFirmware = true;

    # Mesa userspace + RADV Vulkan driver. 32-bit support is required by
    # Steam, Wine, and most Proton titles.
    graphics = {
      enable = true;
      enable32Bit = true;
    };
  };
}
