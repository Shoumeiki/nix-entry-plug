_: {
  # ---------------------------------------------------------------------------
  # Docker daemon.
  #
  # Auto-start on boot so `docker ps` works after a clean login.
  # ellen is already in the `docker` group via modules/core/users.nix,
  # which is what grants /var/run/docker.sock access.
  # ---------------------------------------------------------------------------

  virtualisation.docker = {
    enable = true;
    enableOnBoot = true;
    # Auto-prune dangling images / stopped containers weekly. Keeps the
    # store from filling up with crud from CI experiments. Adjust the
    # `dates` field if a different cadence makes sense later.
    autoPrune = {
      enable = true;
      dates = "weekly";
      flags = [ "--all" ];
    };
  };
}
