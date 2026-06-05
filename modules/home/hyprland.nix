{ ... }:
{
  # -------------------------------------------------------------------------
  # Hyprland window manager config
  # Monitor connector names (DP-1, HDMI-A-1) are KVM/hardware dependent.
  # Run `hyprctl monitors` after first boot to verify connector names.
  # -------------------------------------------------------------------------
  wayland.windowManager.hyprland = {
    enable = true;
    xwayland.enable = true;
    systemd.enable = true;

    settings = {
      monitor = [
        # Primary: 4K @ 120Hz, DisplayPort
        "DP-1,3840x2160@120,0x0,1"
        # Secondary: 4K @ 60Hz, HDMI
        "HDMI-A-1,3840x2560@60,3840x0,1"
        # Fallback: auto-configure any unrecognised monitor
        ",preferred,auto,1"
      ];

      exec-once = [
        # Create headless output immediately so apps never see zero outputs
        # (required for the KVM switch that physically disconnects monitors)
        "hyprctl output create headless"
        "waybar"
        "mako"
        "hypridle"
        "hyprpaper"
        # Clipboard history daemons
        "wl-paste --type text --watch cliphist store"
        "wl-paste --type image --watch cliphist store"
      ];

      # -----------------------------------------------------------------------
      # Input
      # -----------------------------------------------------------------------
      input = {
        kb_layout = "us";
        follow_mouse = 1;
        sensitivity = 0;
        accel_profile = "flat";
      };

      # -----------------------------------------------------------------------
      # General layout
      # -----------------------------------------------------------------------
      general = {
        gaps_in = 4;
        gaps_out = 8;
        border_size = 2;
        layout = "dwindle";
        resize_on_border = true;
      };

      # -----------------------------------------------------------------------
      # Decoration (transparency + blur)
      # -----------------------------------------------------------------------
      decoration = {
        rounding = 8;
        active_opacity = 1.0;
        inactive_opacity = 0.92;

        blur = {
          enabled = true;
          size = 6;
          passes = 2;
          new_optimizations = true;
          ignore_opacity = false;
        };

        shadow = {
          enabled = true;
          range = 12;
          render_power = 3;
        };
      };

      # -----------------------------------------------------------------------
      # Animations
      # -----------------------------------------------------------------------
      animations = {
        enabled = true;
        bezier = [
          "easeOut,0.05,0.9,0.1,1.05"
          "workspaces,0.25,0.1,0.25,1.0"
        ];
        animation = [
          "windows,1,5,easeOut"
          "windowsOut,1,4,default,popin 80%"
          "border,1,10,default"
          "fade,1,7,default"
          "workspaces,1,6,workspaces"
        ];
      };

      # -----------------------------------------------------------------------
      # Dwindle layout
      # -----------------------------------------------------------------------
      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };

      # -----------------------------------------------------------------------
      # Misc
      # -----------------------------------------------------------------------
      misc = {
        force_default_wallpaper = 0;
        disable_hyprland_logo = true;
        # Variable frame rate: reduces GPU usage when nothing is moving
        vfr = true;
      };

      # -----------------------------------------------------------------------
      # Keybindings
      # $mod = Windows/Super key
      # -----------------------------------------------------------------------
      "$mod" = "SUPER";

      bind = [
        # Terminals
        "$mod,Return,exec,footclient"
        "$mod SHIFT,Return,exec,foot"

        # Close / exit
        "$mod,Q,killactive,"
        "$mod SHIFT,Q,exit,"

        # Apps
        "$mod,Space,exec,rofi -show drun"
        "$mod,E,exec,footclient -e yazi"
        "$mod,L,exec,hyprlock"

        # Clipboard picker
        "$mod,V,exec,cliphist list | rofi -dmenu | cliphist decode | wl-copy"

        # Screenshots
        "$mod SHIFT,S,exec,grimblast copy area"
        "$mod,Print,exec,grimblast copy screen"

        # Window management
        "$mod,F,fullscreen,0"
        "$mod SHIFT,F,togglefloating,"
        "$mod,P,pseudo,"
        "$mod,J,togglesplit,"

        # Move focus
        "$mod,left,movefocus,l"
        "$mod,right,movefocus,r"
        "$mod,up,movefocus,u"
        "$mod,down,movefocus,d"
        "$mod,H,movefocus,l"
        "$mod,L,movefocus,r"
        "$mod,K,movefocus,u"
        "$mod,J,movefocus,d"

        # Workspaces: switch
        "$mod,1,workspace,1"
        "$mod,2,workspace,2"
        "$mod,3,workspace,3"
        "$mod,4,workspace,4"
        "$mod,5,workspace,5"
        "$mod,6,workspace,6"
        "$mod,7,workspace,7"
        "$mod,8,workspace,8"
        "$mod,9,workspace,9"
        "$mod,0,workspace,10"

        # Workspaces: move window to
        "$mod SHIFT,1,movetoworkspace,1"
        "$mod SHIFT,2,movetoworkspace,2"
        "$mod SHIFT,3,movetoworkspace,3"
        "$mod SHIFT,4,movetoworkspace,4"
        "$mod SHIFT,5,movetoworkspace,5"
        "$mod SHIFT,6,movetoworkspace,6"
        "$mod SHIFT,7,movetoworkspace,7"
        "$mod SHIFT,8,movetoworkspace,8"
        "$mod SHIFT,9,movetoworkspace,9"
        "$mod SHIFT,0,movetoworkspace,10"

        # Scroll through workspaces
        "$mod,mouse_down,workspace,e+1"
        "$mod,mouse_up,workspace,e-1"
      ];

      # Mouse binds (hold mod + drag)
      bindm = [
        "$mod,mouse:272,movewindow"
        "$mod,mouse:273,resizewindow"
      ];

      # -----------------------------------------------------------------------
      # Window rules
      # -----------------------------------------------------------------------
      windowrulev2 = [
        "suppressevent maximize, class:.*"
        "float,class:^(pavucontrol)$"
        "float,class:^(nm-connection-editor)$"
        "float,class:^(blueman-manager)$"
        "float,title:^(Picture-in-Picture)$"
        "pin,title:^(Picture-in-Picture)$"
        # Games: prefer dedicated GPU (if multi-GPU ever applies)
        "immediate,class:^(steam_app_).*"
      ];
    };
  };

  # Hyprlock screen lock config
  programs.hyprlock = {
    enable = true;
    settings = {
      general = {
        disable_loading_bar = true;
        hide_cursor = true;
      };
      background = [
        {
          monitor = "";
          color = "rgba(30, 30, 46, 1.0)";
          blur_passes = 2;
          blur_size = 8;
        }
      ];
      input-field = [
        {
          monitor = "";
          size = "300, 50";
          position = "0, -100";
          halign = "center";
          valign = "center";
          placeholder_text = "Password";
          hide_input = false;
          rounding = 8;
        }
      ];
    };
  };

  # Hypridle (DPMS + lock trigger)
  services.hypridle = {
    enable = true;
    settings = {
      general = {
        lock_cmd = "pidof hyprlock || hyprlock";
        before_sleep_cmd = "loginctl lock-session";
        after_sleep_cmd = "hyprctl dispatch dpms on";
      };
      listener = [
        {
          timeout = 300;
          on-timeout = "hyprctl dispatch dpms off";
          on-resume = "hyprctl dispatch dpms on";
        }
        {
          timeout = 600;
          on-timeout = "loginctl lock-session";
        }
      ];
    };
  };

  # Hyprpaper wallpaper config
  # Place a wallpaper at ~/Pictures/wallpaper.jpg (or adjust path below).
  services.hyprpaper = {
    enable = true;
    settings = {
      preload = [ "~/Pictures/wallpaper.jpg" ];
      wallpaper = [
        "DP-1,~/Pictures/wallpaper.jpg"
        "HDMI-A-1,~/Pictures/wallpaper.jpg"
      ];
    };
  };
}
