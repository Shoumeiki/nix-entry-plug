{ config, ... }:
{
  # ---------------------------------------------------------------------------
  # Disko: declarative disk layout for unit-01.
  #
  # Layout:
  #   ESP   512M  vfat    /boot
  #   swap  32G   swap    (labelled `swap` for hibernation resume)
  #   root  rest  btrfs   subvolumes: @, @home, @nix, @log, @snapshots, @persist
  #
  # The `@persist` subvolume is created from day one even though Impermanence
  # isn't enabled yet, so the layout is already correct when it lands.
  # ---------------------------------------------------------------------------

  disko.devices.disk.main = {
    type = "disk";
    device = config.nerv.disk.device;
    content = {
      type = "gpt";
      partitions = {
        ESP = {
          size = "512M";
          type = "EF00";
          content = {
            type = "filesystem";
            format = "vfat";
            mountpoint = "/boot";
            mountOptions = [ "umask=0077" ];
          };
        };

        swap = {
          size = "32G";
          content = {
            type = "swap";
            # `mkswap -L swap` so /dev/disk/by-label/swap resolves —
            # matches `boot.resumeDevice` in modules/core/boot.nix.
            extraArgs = [
              "-L"
              "swap"
            ];
            discardPolicy = "both";
          };
        };

        root = {
          size = "100%";
          content = {
            type = "btrfs";
            extraArgs = [
              "-L"
              "nixos"
              "-f"
            ];
            subvolumes = {
              "@" = {
                mountpoint = "/";
                mountOptions = [
                  "compress=zstd"
                  "noatime"
                ];
              };
              "@home" = {
                mountpoint = "/home";
                mountOptions = [
                  "compress=zstd"
                  "noatime"
                ];
              };
              "@nix" = {
                mountpoint = "/nix";
                mountOptions = [
                  "compress=zstd"
                  "noatime"
                ];
              };
              "@log" = {
                mountpoint = "/var/log";
                mountOptions = [
                  "compress=zstd"
                  "noatime"
                ];
              };
              "@snapshots" = {
                mountpoint = "/.snapshots";
                mountOptions = [
                  "compress=zstd"
                  "noatime"
                ];
              };
              "@persist" = {
                mountpoint = "/persist";
                mountOptions = [
                  "compress=zstd"
                  "noatime"
                ];
              };
            };
          };
        };
      };
    };
  };
}
