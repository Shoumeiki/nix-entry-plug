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
    ../../modules/core/nix-tooling.nix
    ../../modules/core/users.nix

    # Hardware modules. amd.nix and ssd.nix are unit-01-appropriate;
    # split them out by host when a non-AMD or non-SSD machine joins.
    ../../modules/hardware/amd.nix
    ../../modules/hardware/audio.nix
    ../../modules/hardware/bluetooth.nix
    ../../modules/hardware/ssd.nix

    # Desktop prerequisites. The actual compositor (Hyprland), greeter,
    # and theming arrive in Phase 4.
    ../../modules/desktop/dconf.nix
    ../../modules/desktop/greetd.nix
    ../../modules/desktop/hyprland.nix
    ../../modules/desktop/nix-ld.nix
    ../../modules/desktop/stylix.nix
    ../../modules/desktop/xdg-portal.nix
  ];

  networking.hostName = "unit-01";

  # Disko target. `/dev/nvme0n1` is the expected enumeration name for
  # unit-01's primary NVMe — still swap to a `/dev/disk/by-id/nvme-...`
  # path before the first real install (Phase 6 pre-install), since the
  # enumeration order isn't guaranteed stable if a second NVMe drive
  # is added later.
  nerv.disk.device = "/dev/nvme0n1";

  # Pin state version. Matches the NixOS release we're installing
  # (26.05 "Yarara", current stable as of 2026-06). Don't change on an
  # installed system — it gates DB / on-disk-format compatibility, not
  # the running nixpkgs version.
  system.stateVersion = "26.05";
}
