_: {
  # Provides a standard ld.so shim so unpatched ELF binaries (editor LSPs,
  # proprietary tools, CI artifacts) don't fail with "No such file or directory".
  # Extend `programs.nix-ld.libraries` if a specific binary needs extra libs.
  programs.nix-ld.enable = true;
}
