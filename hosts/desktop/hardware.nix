{ ... }:
{
  # -------------------------------------------------------------------------
  # Disk layout via Disko
  # -------------------------------------------------------------------------
  # TODO: Verify the NVMe device name before running disko.
  #       Boot from the installer and run: lsblk -d -o NAME,SIZE,MODEL
  #       Then update `device` below if it differs from nvme0n1.
  # -------------------------------------------------------------------------
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

  # -------------------------------------------------------------------------
  # Boot
  # -------------------------------------------------------------------------
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 10;

  # -------------------------------------------------------------------------
  # CPU / GPU
  # -------------------------------------------------------------------------
  hardware.cpu.amd.updateMicrocode = true;

  # AMD RX 7700 XT uses the in-kernel amdgpu driver.
  services.xserver.videoDrivers = [ "amdgpu" ];

  # -------------------------------------------------------------------------
  # Bluetooth
  # -------------------------------------------------------------------------
  hardware.bluetooth = {
    enable = true;
    powerOnBoot = false;
  };
  services.blueman.enable = true;

  # -------------------------------------------------------------------------
  # Kernel: CachyOS (BORE scheduler + LTO)
  # -------------------------------------------------------------------------
  # Provided by the Chaotic Nyx flake (chaotic.nixosModules.default in flake.nix).
  # The binary cache is configured automatically by that module — do not add
  # inputs.nixpkgs.follows to the chaotic input or cache misses will force a
  # full from-source kernel build.
  #
  # During fresh installation, pass the cache manually to nixos-install:
  #   --option extra-substituters 'https://nyx-cache.chaotic.cx/'
  #   --option extra-trusted-public-keys 'nyx-cache.chaotic.cx:dJxTrgMC3V3cFfyIiBQDQorG6k1LsqurH/srpMSq7qk='
  # (see README for the full install command)
  boot.kernelPackages = pkgs.linuxPackages_cachyos-lto;

  # sched-ext: optional runtime scheduler replacement (Linux 6.12+).
  # scx_lavd is well-suited for AMD gaming workloads; leave disabled to use
  # the built-in BORE scheduler, which is already excellent for gaming.
  # services.scx.enable = true;
  # services.scx.scheduler = "scx_lavd";
}
