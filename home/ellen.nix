_: {
  # `./common` is host-agnostic (shell, git, cli tools, neovim, direnv).
  # `./desktop` adds the full graphical session; drop it for headless hosts.
  imports = [
    ./common
    ./desktop
  ];

  home = {
    username = "ellen";
    homeDirectory = "/home/ellen";
    # Don't bump stateVersion on an installed system — it gates migration logic.
    stateVersion = "26.05";
  };

  programs.home-manager.enable = true;
}
