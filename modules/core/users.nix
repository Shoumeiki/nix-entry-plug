{ pkgs, ... }:
{
  # ---------------------------------------------------------------------------
  # User accounts.
  #
  # Phase 2 uses `initialHashedPassword` to avoid the sops-nix bootstrap
  # chicken-and-egg. Phase 7 swaps in `hashedPasswordFile` pointing at a
  # sops-managed secret and this declaration goes away.
  # ---------------------------------------------------------------------------

  programs.fish.enable = true;

  users.users.ellen = {
    isNormalUser = true;
    description = "ellen";
    shell = pkgs.fish;
    extraGroups = [
      "wheel"
      "networkmanager"
      "video"
      "audio"
      "docker"
      "libvirtd"
    ];
    # Hash generated with `mkpasswd -m sha-512`. Phase 7 replaces this
    # with a sops-managed hashedPasswordFile.
    initialHashedPassword = "$6$Tq98roU8mA0GNJol$Zxlnk9jCWfvYmdLyN1IepIi/zL/TAsTqQkF2o9YjIAcTB3Urg7j0o2Ck66P48De6.rfzAlxRV.gKLE5Ckh.7j0";
  };
}
