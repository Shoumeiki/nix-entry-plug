{ pkgs, ... }:
{
  # ---------------------------------------------------------------------------
  # Shell environment: fish + starship + atuin, plus the alias / abbreviation
  # set from nix-entry-plug-spec.md §6.
  #
  # Fish ABBREVIATIONS (not aliases) for almost everything: they expand
  # inline at the prompt so you can see the real command before running it.
  # A few entries stay as aliases / functions where transparency matters
  # more than visibility (URL fetches, the comma binary, etc.).
  # ---------------------------------------------------------------------------

  programs = {
    fish = {
      enable = true;

      shellAbbrs = {
        # ----- Nix workflow ------------------------------------------------
        rebuild = "nh os switch";
        rebuild-boot = "nh os boot";
        rebuild-test = "nh os test";
        dry = "nh os switch --dry";
        update = "nh os switch --update";
        gen = "sudo nix-env -p /nix/var/nix/profiles/system --list-generations";
        gen-diff = "nvd diff /run/current-system /run/booted-system";
        clean = "nh clean all --keep 5 --keep-since 7d";
        search = "nh search";
        repl = "nix repl --expr 'import <nixpkgs> {}'";

        # ----- Filesystem / navigation -------------------------------------
        # eza covers ls/ll/la/tree; zoxide replaces cd via `programs.zoxide.options`
        # in cli-tools.nix. bat/fd/rg/dust/duf/procs/btop substitute for the
        # legacy tools, with bare `\find`, `\grep`, etc. still reachable via
        # the leading-backslash escape.
        ls = "eza --icons --group-directories-first";
        ll = "eza -l --icons --git --group-directories-first";
        la = "eza -la --icons --git --group-directories-first";
        tree = "eza --tree --icons";
        cat = "bat --paging=never";
        find = "fd";
        grep = "rg";
        du = "dust";
        df = "duf";
        ps = "procs";
        top = "btop";

        # ----- Git ---------------------------------------------------------
        gs = "git status";
        gd = "git diff";
        gc = "git commit";
        gca = "git commit --amend";
        gp = "git push";
        gl = "git log --oneline --graph --decorate";
        gco = "git checkout";
        gsw = "git switch";

        # ----- Hyprland / desktop -----------------------------------------
        # Hyprland-only helpers; harmless on headless hosts (hyprctl will
        # just not be on PATH there).
        monitors = "hyprctl monitors";
        clients = "hyprctl clients";
        reload-hypr = "hyprctl reload";

        # ----- Fun / utility ----------------------------------------------
        weather = "curl wttr.in/Melbourne";
        myip = "curl ifconfig.me";
      };

      # Functions live here when an abbreviation isn't enough (multi-line
      # logic, argument handling, etc.). Empty for now; add as patterns emerge.
      functions = { };
    };

    # Starship prompt. Theming is pulled from Stylix automatically via
    # stylix.targets.starship (autoEnable = true in modules/desktop/stylix.nix).
    starship = {
      enable = true;
      enableFishIntegration = true;
    };

    # Atuin: SQLite-backed shell history with optional sync.
    # `--disable-up-arrow` keeps fish's native up-arrow behaviour (history
    # of *this* shell) and binds Ctrl-R to the atuin search instead, which
    # matches muscle memory from bash/zsh users.
    atuin = {
      enable = true;
      enableFishIntegration = true;
      flags = [ "--disable-up-arrow" ];
      # Sync server config (atuin.sh or self-hosted) is set imperatively
      # post-install via `atuin login`. Keeps server URL / credentials
      # out of the public flake.
    };
  };

  # fish needs grep, curl, etc. for some abbreviations. Most are already
  # on PATH via cli-tools.nix; curl is here for `weather` / `myip`.
  home.packages = [ pkgs.curl ];
}
