_:
{
  # ---------------------------------------------------------------------------
  # STUB — Phase 1 placeholder so `nix flake check` evaluates.
  #
  # The values below are replaced in Phase 2:
  #   - boot.loader.*    → modules/core/boot.nix (Limine) +
  #                        hosts/unit-01/specialisations.nix (systemd-boot)
  #   - fileSystems      → hosts/unit-01/disko.nix (Disko + BTRFS subvolumes)
  #   - hardware tweaks  → hosts/unit-01/hardware.nix
  #
  # All real config (users, networking, locale, kernel, etc.) comes from
  # `modules/` and gets imported here once those modules are written.
  # ---------------------------------------------------------------------------

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  networking.hostName = "unit-01";

  # Pin the state version. Matches the NixOS release we're installing
  # (26.05 "Yarara", current stable as of 2026-06).
  # Don't change on an installed system — it gates DB / on-disk-format
  # compatibility, not the running nixpkgs version.
  system.stateVersion = "26.05";
}
