_: {
  # Two bars: primary (DP-1, full modules) and secondary (HDMI-A-1, minimal).
  # Stylix themes CSS via stylix.targets.waybar; this file declares structure only.

  programs.waybar = {
    enable = true;
    systemd.enable = true;

    settings = {
      # ---- Primary bar (left monitor, full info) -------------------------
      primary = {
        output = "DP-1";
        layer = "top";
        position = "top";
        height = 40;
        spacing = 8;

        modules-left = [
          "hyprland/workspaces"
          "hyprland/submap"
        ];
        modules-center = [
          "clock"
        ];
        modules-right = [
          "idle_inhibitor"
          "tray"
          "pulseaudio"
          "bluetooth"
          "network"
          "cpu"
          "memory"
          "custom/gpu"
          "custom/gpu-temp"
          "battery"
        ];

        "hyprland/workspaces" = {
          format = "{name}";
          on-click = "activate";
        };

        # Shows when passthrough submap is active (Super+Esc), so you
        # know your hotkeys are disabled.
        "hyprland/submap" = {
          format = " {}";
          max-length = 16;
          tooltip = false;
        };

        clock = {
          format = "{:%H:%M  %a %d %b}";
          tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
        };

        idle_inhibitor = {
          format = "{icon}";
          format-icons = {
            activated = "󰒳";
            deactivated = "󰒲";
          };
          tooltip = true;
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

        # AMDGPU busy %. card0 is conventional but verify with
        # `ls /sys/class/drm/` if a second GPU shows up.
        "custom/gpu" = {
          format = "󰒋 {}%";
          exec = "cat /sys/class/drm/card0/device/gpu_busy_percent";
          interval = 5;
          tooltip = false;
        };

        # AMDGPU edge temp via lm_sensors. Skips gracefully if `sensors`
        # isn't on PATH (returns empty, module renders nothing).
        "custom/gpu-temp" = {
          format = " {}°";
          exec = "sensors amdgpu-pci-* 2>/dev/null | awk '/edge/ {gsub(/[+°C]/, \"\", $2); print $2; exit}'";
          interval = 10;
          tooltip = false;
        };

        battery = {
          # Harmless on desktops — renders nothing without a battery.
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

      # ---- Secondary bar (right monitor, minimal) ------------------------
      secondary = {
        output = "HDMI-A-1";
        layer = "top";
        position = "top";
        height = 40;
        spacing = 8;

        modules-left = [ "hyprland/workspaces" ];
        modules-center = [ "hyprland/window" ];
        modules-right = [ "clock" ];

        "hyprland/workspaces" = {
          format = "{name}";
          on-click = "activate";
        };

        "hyprland/window" = {
          max-length = 80;
          separate-outputs = true;
        };

        clock = {
          format = "{:%H:%M}";
        };
      };
    };
  };
}
