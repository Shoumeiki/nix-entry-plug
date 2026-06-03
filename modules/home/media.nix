{ pkgs, ... }:
{
  home.packages = with pkgs; [
    mpd
    ncmpcpp
    obs-studio
    tenacity
  ];
}
