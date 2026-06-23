{ inputs, pkgs, ... }:
{
  # Both browsers come from flake inputs (pinned nixpkgs in flake.nix).
  # The $browser keybind in hyprland.nix launches `zen-beta`.

  home.packages = [
    inputs.zen-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
    inputs.helium-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
