{ pkgs, ... }:
{
  # `initialHashedPassword` avoids the sops-nix bootstrap chicken-and-egg.
  # Swap for `hashedPasswordFile` once sops-nix is integrated.
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
