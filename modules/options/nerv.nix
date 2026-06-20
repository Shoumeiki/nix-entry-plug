{ lib, ... }:
{
  # ---------------------------------------------------------------------------
  # nerv.* — self-documenting toggles for host config.
  #
  # Rule of thumb: anything a host needs to declare more than once, or that
  # changes per host, becomes a `nerv.*` option here. Modules then key off
  # the option instead of host-specific imports.
  # ---------------------------------------------------------------------------

  options.nerv = {
    disk.device = lib.mkOption {
      type = lib.types.str;
      example = "/dev/disk/by-id/nvme-Samsung_SSD_980_PRO_1TB_...";
      description = ''
        Primary disk device used by Disko. Prefer a `/dev/disk/by-id/...`
        path on real hardware — it's stable across reboots and won't
        shift if another NVMe drive is added later. `/dev/nvme0n1` or
        `/dev/sda` is acceptable as a working placeholder while you
        wait to look up the by-id path on the target machine.
      '';
    };
  };
}
