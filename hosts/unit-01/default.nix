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
    ../../modules/hardware/firmware.nix
    ../../modules/hardware/ssd.nix

    # Desktop modules.
    ../../modules/desktop/dconf.nix
    ../../modules/desktop/gpu-screen-recorder.nix
    ../../modules/desktop/greetd.nix
    ../../modules/desktop/hyprland.nix
    ../../modules/desktop/nix-ld.nix
    ../../modules/desktop/stylix.nix
    ../../modules/desktop/thunar.nix
    ../../modules/desktop/xdg-portal.nix

    # Gaming.
    ../../modules/gaming/steam.nix

    # Virtualisation.
    ../../modules/virtualisation/docker.nix
    ../../modules/virtualisation/libvirt.nix
  ];

  # Per-user home-manager config. Flake's home-manager NixOS module is
  # imported in flake.nix; this is where the host says "and ellen's home
  # lives at <path>". Future hosts with different users wire up their own
  # users here without touching anything in `modules/`.
  home-manager.users.ellen = import ../../home/ellen.nix;

  networking.hostName = "unit-01";

  # Disko target. `/dev/nvme0n1` is unambiguous on this single-NVMe box;
  # swap to a `/dev/disk/by-id/nvme-...` path if a second NVMe joins.
  nerv.disk.device = "/dev/nvme0n1";

  # Pin state version. Don't change on an installed system — gates DB /
  # on-disk-format compatibility, not the running nixpkgs version.
  system.stateVersion = "26.05";
}
