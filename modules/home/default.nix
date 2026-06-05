{ config, ... }:
{
  imports = [
    ./shell.nix
    ./terminal.nix
    ./hyprland.nix
    ./theming.nix
    ./editors.nix
    ./apps.nix
    ./media.nix
    ./git.nix
    ./virtualisation.nix
  ];

  home.username = "ellen";
  home.homeDirectory = "/home/ellen";

  # XDG user directories
  xdg.userDirs = {
    enable = true;
    createDirectories = true;
    download = "${config.home.homeDirectory}/Downloads";
    documents = "${config.home.homeDirectory}/Documents";
    music = "${config.home.homeDirectory}/Music";
    pictures = "${config.home.homeDirectory}/Pictures";
    videos = "${config.home.homeDirectory}/Videos";
    desktop = null;
    publicShare = null;
    templates = null;
  };

  # Match target Home Manager release branch.
  home.stateVersion = "25.05";
  programs.home-manager.enable = true;
}
