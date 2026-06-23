{ pkgs, ... }:
{
  # Tools with home-manager modules use the module for shell integration,
  # completions, and Stylix theming. Plain binaries go in home.packages.
  programs = {
    # `ls` family. Shell abbreviations in shell.nix override the auto-aliases
    # to give us explicit flag control.
    eza.enable = true;

    # `cat` with syntax highlighting + git blame integration. Stylix themes
    # this via stylix.targets.bat.
    bat.enable = true;

    # `find` (fd), `grep` (rg) — installed as packages below; no HM module
    # needed since their shell integration is just being on PATH.

    # Fuzzy finder. enableFishIntegration adds Ctrl-T / Ctrl-R / Alt-C
    # bindings (atuin in shell.nix takes Ctrl-R; fzf's other bindings
    # remain useful).
    fzf = {
      enable = true;
      enableFishIntegration = true;
    };

    # Smarter cd. `--cmd cd` makes `cd` itself invoke zoxide so the
    # spec-§6 `cd` -> `z` alias is implicit.
    zoxide = {
      enable = true;
      enableFishIntegration = true;
      options = [ "--cmd cd" ];
    };

    btop.enable = true;
    fastfetch.enable = true;
  };

  home.packages = with pkgs; [
    ripgrep
    fd
    tldr
    dust
    duf
    procs
    jq
    yq
  ];
}
