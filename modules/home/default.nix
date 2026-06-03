{ ... }:
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
  ];

  home.username = "ellen";
  home.homeDirectory = "/home/ellen";

  # Match target Home Manager release branch.
  home.stateVersion = "25.05";

  programs.home-manager.enable = true;
}
