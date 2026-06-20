{ ... }:
{
  projectRootFile = "flake.nix";

  # nixfmt-rfc-style — the RFC 166 / nixpkgs-official formatter.
  # treefmt-nix maps `programs.nixfmt` to the rfc-style package by default.
  programs.nixfmt.enable = true;
}
