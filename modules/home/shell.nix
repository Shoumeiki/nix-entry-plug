{ pkgs, ... }:
{
  programs.fish.enable = true;

  programs.starship = {
    enable = true;
    settings = {
      format = "$time $character";
      character = {
        success_symbol = "[>](green)";
        error_symbol = "[>](red)";
      };
      time = {
        disabled = false;
        format = "[$time]($style) ";
      };
    };
  };

  home.packages = with pkgs; [
    eza bat ripgrep fd fzf zoxide
    btop tldr dust duf procs jq yq
    yazi
  ];
}
