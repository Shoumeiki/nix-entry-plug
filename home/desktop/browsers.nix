{ inputs, pkgs, ... }:
{
  # ---------------------------------------------------------------------------
  # Browsers.
  #
  # Both come from flake inputs (pinned to our nixpkgs in flake.nix). The
  # default package install is more resilient to upstream API churn than
  # the bundled home-manager modules, and we don't need the module-only
  # knobs (per-profile config, declarative extension lists).
  #
  # The Hyprland $browser bind launches `zen`; update home/desktop/hyprland.nix
  # if a future Zen release renames the binary.
  # ---------------------------------------------------------------------------

  home.packages = [
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
    inputs.helium-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
