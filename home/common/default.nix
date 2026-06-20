_: {
  # ---------------------------------------------------------------------------
  # Common home-manager modules.
  #
  # Everything in this directory is host-agnostic — it should make sense
  # on a headless server, a desktop, or a laptop. Desktop-specific config
  # lives in ../desktop/.
  # ---------------------------------------------------------------------------

  imports = [
    ./cli-tools.nix
    ./direnv.nix
    ./git.nix
    ./neovim.nix
    ./shell.nix
  ];
}
