_: {
  # `use flake` in a project's `.envrc` activates the devShell on `cd`;
  # nix-direnv caches the activation so repeated entries are instant.
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    # Quiet direnv's per-cd "loading" log unless something actually
    # changes. Keeps prompt output clean.
    silent = true;
  };
}
