{ lib, pkgs, ... }:
{
  # ---------------------------------------------------------------------------
  # Hyprland user config.
  #
  # The compositor itself is enabled at the system level
  # (modules/desktop/hyprland.nix). Setting `package = null` here tells
  # home-manager NOT to install a second copy — we drive the system one
  # with this config.
  #
  # Stylix manages colours, borders, and the lock/idle/wallpaper
  # appearance via stylix.targets.hyprland / hyprlock / hyprpaper, so
  # nothing in this file sets a hex value.
  # ---------------------------------------------------------------------------

  wayland.windowManager.hyprland = {
    enable = true;
    package = null;
    portalPackage = null;

    settings = {
      # ---- Variables -------------------------------------------------------
      "$mainMod" = "SUPER";
      "$terminal" = "foot";
      "$fileManager" = "thunar";
      "$menu" = "rofi -show drun";

      # ---- Monitors --------------------------------------------------------
      # Connectors as enumerated on unit-01: DP-1 = Gigabyte M32U (left),
      # HDMI-A-1 = BenQ RD280UA (right). The KVM switch has no EDID
      # emulation, so monitors vanish on input switch; we create a
      # headless output (placed off to the right at x = 7680, past the
      # BenQ's right edge) and pin workspace 10 to it so windows don't
      # migrate to the wrong real output when displays come back.
      monitor = [
        "DP-1, 3840x2160@144, 0x0, 1"
        "HDMI-A-1, 3840x2560@60, 3840x0, 1"
        "HEADLESS-2, 1920x1080@60, 7680x0, 1"
        ", preferred, auto, 1" # catch-all for anything else
      ];

      # ---- Workspace -> monitor pinning -----------------------------------
      # 1-5 left monitor, 6-9 right, 10 on the headless fallback so
      # nothing real is ever displaced when monitors disappear.
      workspace = [
        "1, monitor:DP-1, default:true"
        "2, monitor:DP-1"
        "3, monitor:DP-1"
        "4, monitor:DP-1"
        "5, monitor:DP-1"
        "6, monitor:HDMI-A-1, default:true"
        "7, monitor:HDMI-A-1"
        "8, monitor:HDMI-A-1"
        "9, monitor:HDMI-A-1"
        "10, monitor:HEADLESS-2, default:true"
      ];

      # ---- Autostart -------------------------------------------------------
      exec-once = [
        # KVM fallback output. Created at startup so workspace 10 has
        # somewhere to live even when DP-1 / DP-2 are present.
        "hyprctl output create headless"

        # Clipboard history daemon. cliphist stores everything wl-paste
        # sees; the Super+Shift+V keybind below pipes it into rofi.
        "wl-paste --type text  --watch cliphist store"
        "wl-paste --type image --watch cliphist store"

        # Polkit agent for GUI sudo prompts.
        "${pkgs.hyprpolkitagent}/libexec/hyprpolkitagent"
      ];

      # ---- Input -----------------------------------------------------------
      input = {
        kb_layout = "us";
        follow_mouse = 1;
        sensitivity = 0;
        accel_profile = "flat"; # no mouse acceleration for the Keychron M5
        touchpad = {
          natural_scroll = true;
          tap-to-click = true;
        };
      };

      # ---- Look / behaviour -----------------------------------------------
      general = {
        gaps_in = 5;
        gaps_out = 10;
        border_size = 2;
        layout = "dwindle";
        allow_tearing = true; # for fullscreen games; per-app rule below
        resize_on_border = true;
      };

      decoration = {
        rounding = 8;
        blur = {
          enabled = true;
          size = 6;
          passes = 2;
          new_optimizations = true;
        };
        shadow = {
          enabled = true;
          range = 8;
          render_power = 3;
        };
      };

      animations.enabled = true;

      dwindle = {
        pseudotile = true;
        preserve_split = true;
        smart_split = false;
      };

      gestures.workspace_swipe = false;

      misc = {
        force_default_wallpaper = 0;
        disable_hyprland_logo = true;
        vfr = true;
      };

      # Per-game tearing opt-in (general.allow_tearing only enables the
      # capability; immediate is what actually requests it).
      windowrulev2 = [
        "immediate, class:^(steam_app_)(.*)$"
        # Common floats.
        "float, class:^(pavucontrol)$"
        "float, class:^(blueman-manager)$"
        "float, class:^(nm-connection-editor)$"
        "float, class:^(\\.?(file-roller|nautilus))$"
        "float, title:^(Picture-in-Picture)$"
        # Idle inhibit while playing video.
        "idleinhibit fullscreen, class:^(mpv|firefox|zen|chrome|chromium)$"
      ];

      # ---- Keybinds --------------------------------------------------------
      bind =
        let
          # 1..9 workspace switching + window-move. Workspace 10 is
          # special (headless fallback); driven by the explicit binds
          # at the bottom.
          ws = map toString (lib.range 1 9);
          workspaceBinds = lib.concatMap (n: [
            "$mainMod, ${n}, workspace, ${n}"
            "$mainMod SHIFT, ${n}, movetoworkspace, ${n}"
          ]) ws;
        in
        [
          # Apps
          "$mainMod, Return, exec, $terminal"
          "$mainMod, D, exec, $menu"
          "$mainMod, E, exec, $fileManager"
          "$mainMod, B, exec, zen"

          # Window management
          "$mainMod, Q, killactive"
          "$mainMod SHIFT, M, exit"
          "$mainMod, V, togglefloating"
          "$mainMod, F, fullscreen"
          "$mainMod, P, pseudo"
          "$mainMod, J, togglesplit"
          "$mainMod, L, exec, hyprlock"

          # Focus
          "$mainMod, left, movefocus, l"
          "$mainMod, right, movefocus, r"
          "$mainMod, up, movefocus, u"
          "$mainMod, down, movefocus, d"

          # Scroll through workspaces
          "$mainMod, mouse_down, workspace, e+1"
          "$mainMod, mouse_up, workspace, e-1"

          # Scratchpad ("special" workspace)
          "$mainMod, S, togglespecialworkspace, magic"
          "$mainMod SHIFT, S, movetoworkspace, special:magic"

          # KVM fallback workspace
          "$mainMod, 0, workspace, 10"
          "$mainMod SHIFT, 0, movetoworkspace, 10"

          # Screenshots
          # Print           → full screen → clipboard
          # Shift+Print     → region      → clipboard
          # $mod+Print      → region      → save to ~/Pictures/Screenshots
          ", Print, exec, grim - | wl-copy"
          "SHIFT, Print, exec, grim -g \"$(slurp)\" - | wl-copy"
          "$mainMod, Print, exec, mkdir -p ~/Pictures/Screenshots && grim -g \"$(slurp)\" ~/Pictures/Screenshots/$(date +%Y%m%d-%H%M%S).png"

          # Clipboard history
          "$mainMod SHIFT, V, exec, cliphist list | rofi -dmenu | cliphist decode | wl-copy"
        ]
        ++ workspaceBinds;

      # Mouse-modifier bindings.
      bindm = [
        "$mainMod, mouse:272, movewindow" # left click + drag
        "$mainMod, mouse:273, resizewindow" # right click + drag
      ];

      # Repeating binds (held key fires repeatedly).
      binde = [
        ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
        ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
      ];

      # Lock-safe binds (continue working while session is locked).
      bindl = [
        ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
        ", XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"
        ", XF86AudioPlay, exec, playerctl play-pause"
        ", XF86AudioNext, exec, playerctl next"
        ", XF86AudioPrev, exec, playerctl previous"
      ];
    };
  };

  # ---------------------------------------------------------------------------
  # Lock / idle / wallpaper.
  # ---------------------------------------------------------------------------

  programs.hyprlock = {
    enable = true;
    # Visuals are Stylix-managed; leave settings empty so we inherit the
    # generated config. Tweak `settings` here when a real customisation
    # is needed.
  };

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
          # 5 min → lock screen
          timeout = 300;
          on-timeout = "loginctl lock-session";
        }
        {
          # 10 min → DPMS off
          timeout = 600;
          on-timeout = "hyprctl dispatch dpms off";
          on-resume = "hyprctl dispatch dpms on";
        }
        {
          # 30 min → suspend
          timeout = 1800;
          on-timeout = "systemctl suspend";
        }
      ];
    };
  };

  services.hyprpaper.enable = true;

  # ---------------------------------------------------------------------------
  # Tools the Hyprland config references on PATH.
  # ---------------------------------------------------------------------------
  home.packages = with pkgs; [
    wl-clipboard # wl-copy / wl-paste
    cliphist # clipboard history daemon
    grim # screenshot capture
    slurp # region select
    playerctl # media keys
    hyprpolkitagent # polkit agent (referenced in exec-once)
  ];
}
