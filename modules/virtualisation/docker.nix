_: {
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
