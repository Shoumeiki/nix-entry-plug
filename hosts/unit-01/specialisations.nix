{ lib, ... }:
{
  # ---------------------------------------------------------------------------
  # systemd-boot fallback specialisation.
  #
  # Picked from the boot menu when a Limine update breaks. Boots the same
  # generation under systemd-boot instead of Limine. Fix Limine, switch back.
  # ---------------------------------------------------------------------------

  specialisation.systemd-boot-fallback.configuration = {
    boot.loader = {
      limine.enable = lib.mkForce false;
      systemd-boot.enable = lib.mkForce true;
    };
  };
}
