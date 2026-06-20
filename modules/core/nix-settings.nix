{ lib, ... }:
{
  # ---------------------------------------------------------------------------
  # Nix daemon, GC, store optimisation, allow-unfree predicate.
  # ---------------------------------------------------------------------------

  nix = {
    settings = {
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      auto-optimise-store = true;
      # Users in `wheel` can configure additional substituters at runtime,
      # so adding a binary cache doesn't require a rebuild.
      trusted-users = [ "@wheel" ];
    };

    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };

    optimise = {
      automatic = true;
      dates = [ "weekly" ];
    };
  };

  # Explicit allow-list — catches accidental unfree additions during
  # package experiments. Add to this list deliberately; do NOT flip
  # `allowUnfree = true`.
  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (lib.getName pkg) [
      # Gaming
      "steam"
      "steam-unwrapped"
      "steam-original"
      "steam-run"
      # Communication
      "discord"
      # Notes
      "obsidian"
    ];
}
