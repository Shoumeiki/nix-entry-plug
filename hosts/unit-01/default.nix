{ inputs, ... }:
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
}
