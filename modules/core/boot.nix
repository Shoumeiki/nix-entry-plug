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

    kernelParams = [
      "resume=/dev/disk/by-label/swap"
      # Suppress most kernel / udev noise during boot so Plymouth has a
      # clean canvas. Errors still surface via journalctl.
      "quiet"
      "splash"
      "udev.log_level=3"
      "rd.systemd.show_status=auto"
    ];

    consoleLogLevel = 0;
    initrd.verbose = false;

    # Splash screen. Stylix themes it via stylix.targets.plymouth.
    plymouth.enable = true;
  };
}
