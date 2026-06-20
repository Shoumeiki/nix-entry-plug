_: {
  # ---------------------------------------------------------------------------
  # Git + SSH client config.
  #
  # Identity: github.com/Shoumeiki. Commit signing uses SSH (not GPG) —
  # same key as auth, no separate keyring to manage. The key itself is
  # generated imperatively post-install (Phase 6 pre-install) since it
  # shouldn't live in the public flake.
  # ---------------------------------------------------------------------------

  programs.git = {
    enable = true;
    userName = "Shoumeiki";
    # GitHub no-reply form. If your account has the "Block command line
    # pushes that expose my email" privacy setting on, GitHub will require
    # the numeric form: `<id>+Shoumeiki@users.noreply.github.com`. Look
    # the ID up at github.com/settings/emails after first push and update
    # this if needed.
    userEmail = "Shoumeiki@users.noreply.github.com";

    signing = {
      format = "ssh";
      key = "~/.ssh/id_ed25519.pub";
      signByDefault = true;
    };

    extraConfig = {
      init.defaultBranch = "main";
      push.autoSetupRemote = true;
      pull.rebase = true;
      # Treat `git rebase` as the default for diverged branches — less
      # noisy than merge commits for a solo workflow.
      merge.conflictStyle = "zdiff3";
      # Better diffs.
      diff.algorithm = "histogram";
    };
  };

  programs.ssh = {
    enable = true;
    # `*` block applies to every host. addKeysToAgent loads the key into
    # the agent the first time it's used, so unlock prompts only happen
    # once per session.
    matchBlocks."*".extraOptions = {
      AddKeysToAgent = "yes";
    };
  };

  # Run ssh-agent as a user systemd service so the agent is up before any
  # shell tries to use it.
  services.ssh-agent.enable = true;
}
