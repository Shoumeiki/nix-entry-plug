_: {
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
