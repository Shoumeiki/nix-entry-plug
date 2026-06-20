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

  # Disko target. Set to the real disk's `by-id` path before the first
  # install (e.g. `/dev/disk/by-id/nvme-...`). `/dev/vda` is a safe
  # placeholder that won't accidentally match real hardware.
  nerv.disk.device = "/dev/vda";

  # Pin state version. Matches the NixOS release we're installing
  # (26.05 "Yarara", current stable as of 2026-06). Don't change on an
  # installed system — it gates DB / on-disk-format compatibility, not
  # the running nixpkgs version.
  system.stateVersion = "26.05";
}
