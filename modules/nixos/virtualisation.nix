{ pkgs, ... }:
{
  # ---------------------------------------------------------------------------
  # KVM kernel module (AMD)
  # ---------------------------------------------------------------------------
  boot.kernelModules = [ "kvm-amd" ];

  # ---------------------------------------------------------------------------
  # libvirt / QEMU-KVM
  # ---------------------------------------------------------------------------
  virtualisation.libvirtd = {
    enable = true;

    qemu = {
      # kvm-only QEMU: no full system emulation, hardware acceleration only
      package = pkgs.qemu_kvm;

      # Run QEMU as root so bridged/macvtap networking works without extra setup.
      # Set to false and configure polkit rules if you prefer rootless.
      runAsRoot = true;

      # OVMF: UEFI firmware for VMs.
      # OVMFFull includes Secure Boot keys and SMM support, both required for
      # a stock Windows 11 install. virt-manager lets you select the firmware
      # variant per-VM at creation time.
      ovmf = {
        enable = true;
        packages = [ pkgs.OVMFFull.fd ];
      };

      # swtpm: software TPM 2.0 emulation.
      # Windows 11 requires TPM 2.0; swtpm provides this without dedicated hardware.
      swtpm.enable = true;
    };
  };

  # ---------------------------------------------------------------------------
  # virt-manager (GUI for creating and managing VMs)
  # ---------------------------------------------------------------------------
  programs.virt-manager.enable = true;

  # ---------------------------------------------------------------------------
  # SPICE USB redirection
  # Lets you pass through USB devices from the host to a running VM session
  # via the SPICE console in virt-manager or virt-viewer.
  # ---------------------------------------------------------------------------
  virtualisation.spiceUSBRedirection.enable = true;

  # ---------------------------------------------------------------------------
  # Firewall: trust libvirt's NAT bridge
  # Without this, nftables will silently drop VM traffic on virbr0.
  # ---------------------------------------------------------------------------
  networking.firewall.trustedInterfaces = [ "virbr0" ];

  # ---------------------------------------------------------------------------
  # User groups
  # libvirtd: allows managing VMs without sudo
  # kvm:      direct access to /dev/kvm
  # ---------------------------------------------------------------------------
  users.users.ellen.extraGroups = [ "libvirtd" "kvm" ];

  # ---------------------------------------------------------------------------
  # Packages
  # ---------------------------------------------------------------------------
  environment.systemPackages = with pkgs; [
    # Full-window SPICE/VNC console for VMs (better than the virt-manager popup)
    virt-viewer

    # RDP + VNC + SSH GUI client
    remmina

    # FreeRDP: RDP library and CLI used as the backend by Remmina.
    # Also available standalone: xfreerdp3 <host> /u:<user> /p:<pass>
    freerdp3

    # Windows VirtIO drivers ISO.
    # Mount this as a CD-ROM in the Windows VM installer to get paravirtual
    # disk (vioscsi/viostor) and network (virtio-net) drivers for best performance.
    virtio-win

    # SPICE GTK widget (embedded console support in virt-manager)
    spice-gtk
  ];

  # ---------------------------------------------------------------------------
  # Looking Glass (optional — GPU passthrough only)
  # ---------------------------------------------------------------------------
  # Looking Glass gives near-native display performance for a Windows VM that
  # has a GPU passed through via VFIO. Requires IOMMU setup, a dedicated GPU,
  # and a shared memory framebuffer region declared in the VM's XML.
  #
  # To enable, uncomment the block below and add the IOMMU kernel params to
  # hardware.nix:
  #   boot.kernelParams = [ "amd_iommu=on" "iommu=pt" ];
  #
  # environment.systemPackages = [ pkgs.looking-glass-client ];
  #
  # boot.extraModulePackages = [ config.boot.kernelPackages.kvmfr ];
  # boot.kernelModules = [ "kvmfr" ];
  # boot.extraModprobeConfig = "options kvmfr static_size_mb=128";
  # services.udev.extraRules = ''
  #   SUBSYSTEM=="kvmfr", OWNER="ellen", GROUP="kvm", MODE="0660"
  # '';
}
