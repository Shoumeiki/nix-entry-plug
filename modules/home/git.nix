{ pkgs, ... }:
{
  programs.git = {
    enable = true;

    userName  = "Shoumeiki";
    userEmail = "shoumeiki@gmail.com";

    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = false;
      push.autoSetupRemote = true;
      core.editor = "nvim";
      merge.conflictstyle = "diff3";
      diff.colorMoved = "default";
      rerere.enabled = true;      # Remember conflict resolutions

      # Credential helpers for remotes
      "credential \"https://github.com\"".helper =
        "!/usr/bin/env gh auth git-credential";
    };

    aliases = {
      st  = "status";
      co  = "checkout";
      br  = "branch";
      lg  = "log --oneline --graph --decorate --all";
      unstage = "restore --staged";
      undo    = "reset HEAD~1 --mixed";
    };

    # delta: better diffs (catppuccin theme applied via catppuccin HM module)
    delta = {
      enable = true;
      options = {
        navigate = true;
        side-by-side = false;
        line-numbers = true;
        syntax-theme = "Catppuccin Mocha";
      };
    };

    ignores = [
      ".direnv/"
      ".env"
      ".env.*"
      "*.agekey"
      "result"
      "result-*"
    ];
  };

  # GitHub CLI (for authentication + gh auth git-credential)
  programs.gh = {
    enable = true;
    settings = {
      git_protocol = "ssh";
      editor = "nvim";
    };
  };
}
