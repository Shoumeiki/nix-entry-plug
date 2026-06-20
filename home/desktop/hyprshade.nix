{ pkgs, ... }:
{
  # ---------------------------------------------------------------------------
  # hyprshade: blue-light filter for Hyprland.
  #
  # hyprshade ships only as a CLI tool — there's no home-manager service
  # module for it. We declare the schedule in
  # ~/.config/hyprshade/config.toml and start the user systemd unit that
  # ships with the package, which periodically re-evaluates the schedule.
  #
  # Times use 24-hour local time. Adjust to taste once on real hardware.
  # ---------------------------------------------------------------------------

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
      ExecStart = "${pkgs.hyprshade}/bin/hyprshade auto";
      Restart = "on-failure";
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
