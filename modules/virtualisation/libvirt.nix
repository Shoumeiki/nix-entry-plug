{ pkgs, ... }:
{
  # ---------------------------------------------------------------------------
  # QEMU/KVM via libvirt + virt-manager GUI.
  #
  # Membership of `libvirtd` group (granted to ellen in
  # modules/core/users.nix) is what makes virt-manager work without sudo.
  # UEFI firmware (OVMF) now ships bundled with QEMU upstream, so the
  # old `qemu.ovmf` submodule is gone — enabling libvirtd is enough.
  # swtpm provides virtual TPMs (needed for modern Windows guests,
  # secureboot tests, etc.).
  # ---------------------------------------------------------------------------

  virtualisation.libvirtd = {
    enable = true;
    qemu = {
      package = pkgs.qemu_kvm;
      runAsRoot = true;
      swtpm.enable = true;
    };
  };

  programs.virt-manager.enable = true;

  # USB device passthrough discovery (plug a controller in, see it in
  # virt-manager). Cheap to enable; safe to drop if you never passthrough.
  services.spice-vdagentd.enable = true;
}
