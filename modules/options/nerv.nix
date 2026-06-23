{ lib, ... }:
{
  # Per-host values surfaced as options so modules can read them without
  # direct host-specific imports.
  options.nerv = {
    disk.device = lib.mkOption {
      type = lib.types.str;
      example = "/dev/disk/by-id/nvme-Samsung_SSD_980_PRO_1TB_...";
      description = ''
        Primary disk device used by Disko. Use a `/dev/disk/by-id/...`
        path on real hardware — it's stable across reboots and won't
        shift if another NVMe drive is added later. Bare paths like
        `/dev/nvme0n1` or `/dev/sda` work but are fragile when more
        than one disk is present.
      '';
    };
  };
}
