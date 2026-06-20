{ pkgs, ... }:
{
  # ---------------------------------------------------------------------------
  # User accounts.
  #
  # `initialHashedPassword` avoids the sops-nix bootstrap chicken-and-egg —
  # the password hash is committed and applied at first install. Phase 7
  # swaps this in for `hashedPasswordFile` pointing at a sops-managed
  # secret; the line below goes away then.
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
    # Hash generated with `mkpasswd -m sha-512`.
    initialHashedPassword = "$6$Tq98roU8mA0GNJol$Zxlnk9jCWfvYmdLyN1IepIi/zL/TAsTqQkF2o9YjIAcTB3Urg7j0o2Ck66P48De6.rfzAlxRV.gKLE5Ckh.7j0";
  };
}
