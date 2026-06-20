{ pkgs, ... }:
{
  # ---------------------------------------------------------------------------
  # Nix formatter selection for treefmt.
  # ---------------------------------------------------------------------------

  projectRootFile = "flake.nix";

  # nixfmt is the RFC 166 / nixpkgs-official formatter. Pinning the
  # package keeps treefmt from picking up an unexpected default if the
  # alias situation changes upstream.
  programs.nixfmt = {
    enable = true;
    package = pkgs.nixfmt;
  };
}
