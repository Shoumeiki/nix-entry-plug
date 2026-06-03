{ ... }:
{
  imports = [
    ./hardware.nix
    ./monitors.nix

    ../../modules/nixos/desktop.nix
    ../../modules/nixos/gaming.nix
    ../../modules/nixos/docker.nix
    ../../modules/nixos/networking.nix
    ../../modules/nixos/users.nix
  ];

  networking.hostName = "nixos-desktop";

  nixpkgs.config.allowUnfree = true;

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  # Required for stateful paths and module defaults.
  system.stateVersion = "25.05";

  # Secrets loaded by sops-nix module.
  sops.defaultSopsFile = ../../secrets/secrets.yaml;
  sops.age.keyFile = "/home/ellen/.config/sops/age/keys.txt";
}
