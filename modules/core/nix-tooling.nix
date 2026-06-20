{ pkgs, ... }:
{
  # ---------------------------------------------------------------------------
  # Nix workflow helpers.
  #
  #   nh   — friendlier `nixos-rebuild` / `home-manager` wrapper used by
  #          the justfile (`switch`, `boot`, `test`, `clean all`).
  #   nom  — nix-output-monitor, prettier build progress output.
  #   nvd  — nix-version-diff, diff between two system generations.
  #   comma — run anything from nixpkgs without installing it (`, hello`).
  # ---------------------------------------------------------------------------

  environment.systemPackages = with pkgs; [
    nh
    nix-output-monitor
    nvd
    comma
  ];

  programs = {
    # nix-index builds a database mapping executables to the nixpkgs
    # attribute that provides them. Powers `nix-locate` and `comma`'s
    # lookup.
    nix-index.enable = true;

    # Disable the upstream "command not found" handler — nix-index's
    # version is more useful and replaces it.
    command-not-found.enable = false;
  };
}
