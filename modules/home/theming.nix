{ pkgs, ... }:
{
  fonts.fontconfig.enable = true;

  home.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    merriweather
    atkinson-hyperlegible
    nwg-look
    qt5ct
    qt6ct
    kvantum
  ];
}
