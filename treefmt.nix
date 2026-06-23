{ pkgs, ... }:
{
  projectRootFile = "flake.nix";

  # Pin the package explicitly so treefmt isn't affected by future alias changes.
  programs.nixfmt = {
    enable = true;
    package = pkgs.nixfmt;
  };
}
