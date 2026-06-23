{ pkgs, ... }:
{
  # Fish ABBREVIATIONS (not aliases): they expand inline at the prompt so
  # you can see the real command before running it.

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
        gen-diff = "nvd diff /run/booted-system /run/current-system";
        clean = "nh clean all --keep 5 --keep-since 7d";
        search = "nh search";
        repl = "nix repl --expr 'import <nixpkgs> {}'";

        # ----- Filesystem / navigation -------------------------------------
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

    };

    # Stylix themes starship automatically via stylix.targets.starship.
    starship = {
      enable = true;
      enableFishIntegration = true;
    };

    # Atuin: SQLite-backed shell history with optional sync.
    # `--disable-up-arrow` keeps fish's native up-arrow behaviour (history
    # of *this* shell) and binds Ctrl-R to the atuin search instead.
    # `enter_accept = false` makes Enter on a selected result paste
    # rather than run immediately — friendlier when results are close
    # but not identical to what you want.
    atuin = {
      enable = true;
      enableFishIntegration = true;
      flags = [ "--disable-up-arrow" ];
      settings = {
        enter_accept = false;
        filter_mode_shell_up_key_down = "session";
        style = "compact";
      };
    };
  };

  home.packages = [ pkgs.curl ];
}
