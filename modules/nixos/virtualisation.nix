{ pkgs, ... }:
{
  boot.kernelModules = [ "kvm-amd" ];

  virtualisation.libvirtd = {
    enable = true;

    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = true;
      ovmf = {
        enable = true;
        packages = [ pkgs.OVMFFull.fd ];
      };
      swtpm.enable = true;
    };
  };

  programs.virt-manager.enable = true;
  virtualisation.spiceUSBRedirection.enable = true;

  networking.firewall.trustedInterfaces = [ "virbr0" ];

  users.users.ellen.extraGroups = [ "libvirtd" "kvm" ];

  environment.systemPackages = with pkgs; [
    virt-viewer   # Full-window SPICE/VNC console
    remmina       # RDP + VNC + SSH GUI client
    freerdp3      # RDP backend; also usable standalone: xfreerdp3 <host> /u:<user> /p:<pass>
    virtio-win    # Windows VirtIO drivers ISO — mount as CD-ROM in VM installer
    spice-gtk     # SPICE GTK widget for virt-manager embedded consoles
  ];

  # ---------------------------------------------------------------------------
  # Looking Glass (optional — GPU passthrough only)
  # Uncomment and add to hardware.nix when ready:
  #   boot.kernelParams = [ "amd_iommu=on" "iommu=pt" ];
  #
  # environment.systemPackages = [ pkgs.looking-glass-client ];
  # boot.extraModulePackages = [ config.boot.kernelPackages.kvmfr ];
  # boot.kernelModules = [ "kvmfr" ];
  # boot.extraModprobeConfig = "options kvmfr static_size_mb=128";
  # services.udev.extraRules = ''
  #   SUBSYSTEM=="kvmfr", OWNER="ellen", GROUP="kvm", MODE="0660"
  # '';
  # ---------------------------------------------------------------------------
}
