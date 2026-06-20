{ pkgs, ... }:
{
  # ---------------------------------------------------------------------------
  # CLI tooling: modern replacements for the classic Unix utilities plus
  # a few extras.
  #
  # Tools with home-manager modules use the module (which sets up shell
  # integration, completions, and Stylix theming automatically). Plain
  # binaries with no shell wiring go in home.packages.
  # ---------------------------------------------------------------------------

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

    # Process / resource monitor. Replaces `top` / `htop`.
    btop.enable = true;

    # System info on shell start (decorative; the actual exec-once is
    # in home/desktop/fun.nix once the desktop layer lands).
    fastfetch.enable = true;
  };

  # Plain binaries.
  home.packages = with pkgs; [
    ripgrep # rg
    fd # fd
    tldr # short man pages
    dust # du
    duf # df
    procs # ps
    jq # JSON
    yq # YAML / TOML / XML
  ];
}
