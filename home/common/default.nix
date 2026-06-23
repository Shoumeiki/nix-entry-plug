_: {
  # Host-agnostic modules — safe on headless servers and desktops alike.
  # Desktop-specific config lives in ../desktop/.
  imports = [
    ./cli-tools.nix
    ./direnv.nix
    ./git.nix
    ./neovim.nix
    ./nix-tools.nix
    ./shell.nix
  ];
}
