{ lib, ... }:
{
  # Fallback: boot the same generation under systemd-boot when Limine breaks.
  specialisation.systemd-boot-fallback.configuration = {
    boot.loader = {
      limine.enable = lib.mkForce false;
      systemd-boot.enable = lib.mkForce true;
    };
  };
}
