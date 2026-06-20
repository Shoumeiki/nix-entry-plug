_: {
  # ---------------------------------------------------------------------------
  # Per-user home-manager entrypoint for ellen.
  #
  # Imports common (host-agnostic) config now; the desktop layer is added
  # in batch 2 of Phase 5 once the home-manager wiring is proven to work.
  # ---------------------------------------------------------------------------

  imports = [ ./common ];

  home = {
    username = "ellen";
    homeDirectory = "/home/ellen";
    # Pin home-manager state version to match system stateVersion. Don't
    # bump on an installed system — gates internal migration logic.
    stateVersion = "26.05";
  };

  # Let home-manager manage itself.
  programs.home-manager.enable = true;
}
