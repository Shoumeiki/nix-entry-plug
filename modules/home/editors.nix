{ pkgs, ... }:
{
  home.packages = with pkgs; [
    zed-editor
    neovim
  ];
}
