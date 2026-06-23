{ pkgs, ... }:
{
  # Nix workflow tools for day-to-day system management.
  # Also available in the project devShell (flake.nix) for pre-activation bootstrap.
  home.packages = with pkgs; [
    nh # nixos-rebuild / home-manager wrapper (used by shell abbreviations)
    nix-output-monitor # prettier build progress (nom)
    nvd # generation diff viewer
    comma # run anything from nixpkgs without installing it
  ];
}
