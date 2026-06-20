{ pkgs, ... }:
{
  # ---------------------------------------------------------------------------
  # Boot, kernel, hibernation.
  # Host-agnostic: any host that uses this module must label its swap
  # partition `swap` (Disko handles this in hosts/<host>/disko.nix).
  # ---------------------------------------------------------------------------

  boot = {
    # Primary bootloader: Limine.
    # A systemd-boot specialisation lives alongside it in
    # hosts/<host>/specialisations.nix so a broken Limine update never
    # leaves the machine unbootable.
    loader = {
      limine = {
        enable = true;
        efiSupport = true;
      };
      efi.canTouchEfiVariables = true;
    };

    # Zen kernel — desktop-tuned, lower latency than vanilla.
    kernelPackages = pkgs.linuxPackages_zen;

    # Hibernation: resume from the swap partition labelled `swap`.
    # Setting `resumeDevice` adds the corresponding `resume=` kernel param
    # automatically, but we set it explicitly for clarity / belt-and-braces.
    resumeDevice = "/dev/disk/by-label/swap";
    kernelParams = [ "resume=/dev/disk/by-label/swap" ];
  };
}
