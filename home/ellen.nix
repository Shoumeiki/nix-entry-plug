_: {
  # ---------------------------------------------------------------------------
  # Per-user home-manager entrypoint for ellen.
  #
  # `./common` is host-agnostic (shell, git, cli tools, neovim, direnv).
  # `./desktop` adds Hyprland + waybar + rofi + terminals + the rest of the
  # graphical session; safe to drop from any future headless host's
  # entrypoint.
  # ---------------------------------------------------------------------------

  imports = [
    ./common
    ./desktop
  ];

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
