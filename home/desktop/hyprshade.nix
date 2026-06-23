{ pkgs, ... }:
{
  # hyprshade has no home-manager module; the schedule is declared in
  # ~/.config/hyprshade/config.toml and re-evaluated every 15 minutes via systemd.

  home.packages = [ pkgs.hyprshade ];

  xdg.configFile."hyprshade/config.toml".text = ''
    # Default no-shader during the day; warm shader sunset → sunrise.
    [[shades]]
    name = "blue-light-filter"
    default = true
    start_time = 19:00:00
    end_time = 06:00:00
  '';

  systemd.user.services.hyprshade = {
    Unit = {
      Description = "hyprshade scheduler";
      PartOf = [ "graphical-session.target" ];
      After = [ "graphical-session.target" ];
    };
    Service = {
      # `hyprshade auto` consults the schedule, applies (or clears) the
      # shader, and exits — a true one-shot. `Restart` doesn't apply to
      # oneshot units; periodic re-evaluation is driven by the timer
      # below.
      Type = "oneshot";
      ExecStart = "${pkgs.hyprshade}/bin/hyprshade auto";
    };
    Install.WantedBy = [ "graphical-session.target" ];
  };

  systemd.user.timers.hyprshade = {
    Unit.Description = "Re-evaluate hyprshade schedule periodically";
    Timer = {
      OnCalendar = "*:0/15"; # every 15 minutes
      Persistent = true;
    };
    Install.WantedBy = [ "timers.target" ];
  };
}
