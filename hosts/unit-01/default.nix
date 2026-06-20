{ inputs, lib, ... }:
{
  imports = [
    # Disko module (provides `disko.devices.*` options).
    inputs.disko.nixosModules.disko

    # Host-specific bits.
    ./hardware.nix
    ./disko.nix
    ./specialisations.nix

    # Custom options namespace.
    ../../modules/options/nerv.nix

    # Core system modules (host-agnostic).
    ../../modules/core/boot.nix
    ../../modules/core/locale.nix
    ../../modules/core/networking.nix
    ../../modules/core/nix-settings.nix
    ../../modules/core/users.nix
  ];

  networking.hostName = "unit-01";

  # Disko target. `/dev/vda` for VM testing — swap to a `by-id` path
  # (e.g. `/dev/disk/by-id/nvme-...`) when installing on real hardware.
  nerv.disk.device = "/dev/vda";

  # Pin state version. Matches the NixOS release we're installing
  # (26.05 "Yarara", current stable as of 2026-06). Don't change on an
  # installed system — it gates DB / on-disk-format compatibility, not
  # the running nixpkgs version.
  system.stateVersion = "26.05";

  # ---------------------------------------------------------------------------
  # VM-only overrides (applied by `nixos-rebuild build-vm[-with-bootloader]`).
  #
  # Disko declares a swap partition and BTRFS filesystems that only exist
  # on real disks. In a VM build those devices don't exist, so:
  #   - systemd hangs waiting for the swap unit
  #   - kernel can't resume from a non-existent swap
  #   - Limine fails to install into the virtual ESP
  #
  # vmVariant strips those for the VM build only — real installs are
  # unaffected.
  # ---------------------------------------------------------------------------
  virtualisation.vmVariant = {
    # Headless VM: tell the qemu-vm module to skip display setup, wire
    # the serial console to stdio, and add the matching `console=`
    # kernel parameter on its own. Without this the generated run
    # script adds `-display sdl` and our `-nographic` override leaves
    # the kernel writing to a console nothing is reading.
    virtualisation.graphics = false;

    # No swap in the VM, so don't let disko declare one and don't try
    # to resume from it.
    swapDevices = lib.mkForce [ ];

    boot = {
      resumeDevice = lib.mkForce "";

      # `build-vm-with-bootloader` would otherwise try to install Limine
      # into the virtual ESP. Fall back to systemd-boot for the VM.
      loader = {
        limine.enable = lib.mkForce false;
        systemd-boot.enable = lib.mkForce true;
      };

      # Crank dmesg verbosity so we can see what's happening if boot
      # stalls. Console wiring is handled by `virtualisation.graphics`.
      kernelParams = [ "loglevel=7" ];
    };
  };
}
