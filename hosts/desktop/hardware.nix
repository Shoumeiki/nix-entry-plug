{ pkgs, ... }:
{
  # TODO: Replace with generated hardware config and Disko layout.
  # Suggested bootstrap flow:
  # 1) Generate hardware config
  # 2) Add disko device layout (Btrfs subvolumes: @ @home @nix @log @snapshots)
  # 3) Apply and validate

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # AMD microcode
  hardware.cpu.amd.updateMicrocode = true;

  # If/when enabling CachyOS kernel, swap this line:
  # boot.kernelPackages = pkgs.linuxPackages_cachyos-lto;
}
