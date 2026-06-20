{ pkgs, ... }:
{
  projectRootFile = "flake.nix";

  # nixfmt (formerly `nixfmt-rfc-style`) — the RFC 166 / nixpkgs-official
  # formatter. `pkgs.nixfmt-rfc-style` is now an alias of `pkgs.nixfmt`,
  # so we pin the package explicitly to dodge the deprecation warning
  # that treefmt-nix would otherwise surface.
  programs.nixfmt = {
    enable = true;
    package = pkgs.nixfmt;
  };
}
