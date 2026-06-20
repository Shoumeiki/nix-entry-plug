_: {
  # ---------------------------------------------------------------------------
  # waybar: status bar.
  #
  # Stylix themes both the JSON config (icon set choices) and the CSS
  # (colours, fonts) via stylix.targets.waybar. This file only declares
  # *structure* — what modules appear where.
  # ---------------------------------------------------------------------------

  programs.waybar = {
    enable = true;
    systemd.enable = true;

    settings.mainBar = {
      layer = "top";
      position = "top";
      height = 30;
      spacing = 6;

      modules-left = [
        "hyprland/workspaces"
        "hyprland/window"
      ];
      modules-center = [ "clock" ];
      modules-right = [
        "tray"
        "pulseaudio"
        "bluetooth"
        "network"
        "cpu"
        "memory"
        "battery"
      ];

      "hyprland/workspaces" = {
        format = "{name}";
        on-click = "activate";
      };

      "hyprland/window" = {
        max-length = 60;
        separate-outputs = true;
      };

      clock = {
        format = "{:%H:%M  %a %d %b}";
        tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
      };

      pulseaudio = {
        format = "{volume}% {icon}";
        format-muted = "muted ";
        format-icons = {
          headphone = "";
          default = [
            ""
            ""
            ""
          ];
        };
        on-click = "pavucontrol";
        scroll-step = 5;
      };

      bluetooth = {
        format = " {status}";
        format-connected = " {device_alias}";
        on-click = "blueman-manager";
      };

      network = {
        format-wifi = "  {essid} ({signalStrength}%)";
        format-ethernet = "  {ifname}";
        format-disconnected = "no network";
        tooltip-format = "{ipaddr} via {gwaddr}";
        on-click = "nm-connection-editor";
      };

      cpu = {
        format = " {usage}%";
        interval = 5;
      };

      memory = {
        format = " {percentage}%";
        interval = 5;
      };

      battery = {
        # Harmless on desktops without a battery — module just doesn't render.
        format = "{capacity}% {icon}";
        format-icons = [
          ""
          ""
          ""
          ""
          ""
        ];
        states = {
          warning = 30;
          critical = 15;
        };
      };

      tray = {
        spacing = 10;
      };
    };
  };
}
