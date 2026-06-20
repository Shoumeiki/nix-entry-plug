_: {
  # ---------------------------------------------------------------------------
  # nix-ld: shim that lets unpatched dynamic ELF binaries find their
  # libraries on NixOS.
  #
  # Without this, anything not built against /nix/store paths (proprietary
  # tools, language-server binaries shipped by editor plugins, downloaded
  # release builds, some pre-built CI artefacts) fails with
  # "No such file or directory" on the dynamic linker. nix-ld supplies a
  # standard ld.so at /lib64/ld-linux-x86-64.so.2 and a configurable
  # library set on LD_LIBRARY_PATH.
  #
  # The default library set covers most common cases (glibc, gcc-libs,
  # zlib, openssl, etc.). Extend `programs.nix-ld.libraries` if a
  # specific binary needs more.
  # ---------------------------------------------------------------------------

  programs.nix-ld.enable = true;
}
