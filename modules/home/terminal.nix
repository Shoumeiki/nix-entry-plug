{ ... }:
{
  programs.foot = {
    enable = true;
    server.enable = true;

    settings = {
      main = {
        font = "JetBrainsMono Nerd Font:size=12";
        dpi-aware = "auto";
        pad = "8x8 center";
      };
      mouse = {
        hide-when-typing = "yes";
      };
      scrollback = {
        lines = 10000;
        multiplier = 3.0;
      };
      url = {
        launch = "xdg-open \${url}";
        osc8-underline = "url-mode";
      };
    };
  };
}
