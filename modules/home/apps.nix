{ pkgs, ... }:
{
  home.packages = with pkgs; [
    librewolf
    signal-desktop
    discord
    obsidian
    libreoffice
    zathura
    mpv
    imv
    krita
  ];
}
