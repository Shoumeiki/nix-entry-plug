{ pkgs, ... }:
{
  # libvirtd group membership (users.nix) grants virt-manager access without sudo.
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
