{ inputs, ... }:
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

  # Required for stateful paths and module defaults.
  system.stateVersion = "25.05";

  # Secrets loaded by sops-nix module.
  sops.defaultSopsFile = ../../secrets/secrets.yaml;
}
