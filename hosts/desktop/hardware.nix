{ ... }:
{
  # TODO: Verify the NVMe device name before running disko.
  #       Boot from the installer and run: lsblk -d -o NAME,SIZE,MODEL
  #       Then update `device` below if it differs from nvme0n1.
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/nvme0n1";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              priority = 1;
              size = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            root = {
              priority = 2;
              size = "100%";
              content = {
                type = "btrfs";
                extraArgs = [ "-L" "nixos" "-f" ];
                subvolumes = {
                  "@" = {
                    mountpoint = "/";
                    mountOptions = [ "compress=zstd" "noatime" ];
                  };
                  "@home" = {
                    mountpoint = "/home";
                    mountOptions = [ "compress=zstd" "noatime" ];
                  };
                  "@nix" = {
                    mountpoint = "/nix";
                    mountOptions = [ "compress=zstd" "noatime" ];
                  };
                  "@log" = {
                    mountpoint = "/var/log";
                    mountOptions = [ "compress=zstd" "noatime" ];
                  };
                  "@snapshots" = {
                    mountpoint = "/.snapshots";
                    mountOptions = [ "compress=zstd" "noatime" ];
                  };
                };
              };
            };
          };
        };
      };
    };
  };

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 10;

  hardware.cpu.amd.updateMicrocode = true;

  # AMD RX 7700 XT uses the in-kernel amdgpu driver.
  services.xserver.videoDrivers = [ "amdgpu" ];

  hardware.bluetooth = {
    enable = true;
    powerOnBoot = false;
  };
  services.blueman.enable = true;

  # boot.kernelPackages = pkgs.linuxPackages_cachyos-lto;

  # sched-ext: optional runtime scheduler replacement (Linux 6.12+).
  # scx_lavd is well-suited for AMD gaming workloads; leave disabled to use
  # the built-in BORE scheduler, which is already excellent for gaming.
  # services.scx.enable = true;
  # services.scx.scheduler = "scx_lavd";
}
