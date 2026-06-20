_: {
  # ---------------------------------------------------------------------------
  # Git + SSH client config.
  #
  # Identity: github.com/Shoumeiki. Commit signing uses SSH (not GPG) —
  # same key as auth, no separate keyring to manage. The key itself is
  # generated imperatively post-install since it shouldn't live in the
  # public flake.
  # ---------------------------------------------------------------------------

  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "Shoumeiki";
        email = "186657365+Shoumeiki@users.noreply.github.com";
        # SSH key used for commit signing. Same key as auth.
        signingkey = "~/.ssh/id_ed25519.pub";
      };

      # SSH-based signing (not GPG). The `gpgsign` keys govern signing for
      # any configured `gpg.format` — the naming is a git historical
      # artefact, the behaviour applies to ssh signatures too.
      gpg.format = "ssh";
      commit.gpgsign = true;
      tag.gpgsign = true;

      init.defaultBranch = "main";
      push.autoSetupRemote = true;
      pull.rebase = true;
      # Three-way conflict markers with a common-ancestor block — much
      # easier to resolve than the default two-way diff.
      merge.conflictStyle = "zdiff3";
      diff.algorithm = "histogram";
    };
  };

  programs.ssh = {
    enable = true;

    # Opt out of the home-manager-supplied default block so future HM
    # upgrades can't silently change client behaviour. The settings we
    # actually want are declared explicitly below.
    enableDefaultConfig = false;

    settings."*" = {
      # Load keys into ssh-agent on first use; one passphrase prompt per
      # session instead of per-connection.
      AddKeysToAgent = "yes";

      # Connection multiplexing: reuse a single TCP connection for
      # subsequent sessions to the same host. Big speedup for tools that
      # open many short-lived ssh connections (git, rsync, ansible).
      ControlMaster = "auto";
      ControlPath = "~/.ssh/master-%r@%n:%p";
      ControlPersist = "10m";

      # Keep the connection alive through stateful middleboxes
      # (corporate firewalls, some home routers).
      ServerAliveInterval = 60;
      ServerAliveCountMax = 3;

      # Don't leak host names into ~/.ssh/known_hosts in cleartext.
      HashKnownHosts = "yes";
    };
  };

  # Run ssh-agent as a user systemd service so the agent is up before any
  # shell tries to use it.
  services.ssh-agent.enable = true;
}
