{ inputs, pkgs, ... }:
{
  # ---------------------------------------------------------------------------
  # Browsers.
  #
  # Both come from flake inputs (pinned to our nixpkgs in flake.nix). We
  # install the default package from each flake rather than going through
  # their home-manager modules — the package install is more resilient to
  # upstream API churn and we don't currently need any of the module-only
  # knobs (per-profile config, declarative extension lists, etc.).
  #
  # The Hyprland $mod+B binding launches `zen` (Zen's canonical binary
  # name); update home/desktop/hyprland.nix if a future Zen release
  # renames it.
  # ---------------------------------------------------------------------------

  home.packages = [
    inputs.zen-browser.packages.${pkgs.system}.default
    inputs.helium-browser.packages.${pkgs.system}.default
  ];
}
