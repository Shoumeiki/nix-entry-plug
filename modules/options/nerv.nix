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
        path on real hardware (stable across reboots); `/dev/vda` is fine
        for VM testing.
      '';
    };
  };
}
