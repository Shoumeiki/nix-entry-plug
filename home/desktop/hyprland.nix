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
  # Stylix manages colours, borders, and the lock/idle/wallpaper appearance
  # via stylix.targets.hyprland / hyprlock / hyprpaper, so nothing in this
  # file sets a hex value.
  # ---------------------------------------------------------------------------

  wayland.windowManager.hyprland = {
    enable = true;
    package = null;
    portalPackage = null;

    # Pin the rendered config format. Home-manager flips the default to
    # "lua" on stateVersion >= 26.05 (we're on 26.05); without this pin
    # the file below would be emitted as Lua syntax and fail to parse.
    # Hyprland still supports the hyprlang format; it's just no longer
    # the upstream-preferred path. Revisit when we're ready to port the
    # full config to Lua.
    configType = "hyprlang";

    settings = {
      # ---- Variables -------------------------------------------------------
      "$mainMod" = "SUPER";
      "$terminal" = "foot";
      "$fileManager" = "thunar";
      "$menu" = "rofi -show drun";
      "$browser" = "zen";

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
      # cliphist, hyprpaper, hypridle, hyprpolkitagent all run as user
      # systemd services declared elsewhere in this file. exec-once is
      # reserved for things that genuinely need to fire from Hyprland.
      exec-once = [
        # KVM fallback output. Created at startup so workspace 10 has
        # somewhere to live even when DP-1 / HDMI-A-1 are present.
        "hyprctl output create headless"
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

      # ---- Cursor ----------------------------------------------------------
      cursor = {
        # Hide the cursor after a few seconds of no movement. Stops the
        # arrow squatting in the middle of a 4K video.
        inactive_timeout = 4;
        no_warps = true;
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
        # Hide the terminal that launched a GUI app until the app exits.
        # Big QoL on a tiling WM.
        enable_swallow = true;
        swallow_regex = "^(foot|kitty)$";
        # Background activations (notification clicks, electron deep
        # links) actually raise + focus. The second option un-fullscreens
        # the current window so the new one isn't hidden under it.
        focus_on_activate = true;
        new_window_takes_over_fullscreen = 2;
      };

      # Let bar / notifications / launcher participate in Hyprland's blur.
      layerrule = [
        "blur, waybar"
        "ignorezero, waybar"
        "blur, notifications"
        "ignorezero, notifications"
        "blur, rofi"
        "ignorezero, rofi"
      ];

      # Window rules. Hyprland 0.55 retired `windowrulev2` (the parser
      # now rejects it as deprecated) and replaced it with a v3 syntax
      # under the same `windowrule` keyword:
      #   - match props use `match:<prop> <value>` (space, not colon)
      #   - effects are `<effect> <value>` (booleans need an explicit
      #     truthy value)
      #   - effect names are lower_snake_case (`idle_inhibit`, not
      #     `idleinhibit`)
      #   - multiple match props / effects are comma-separated within a
      #     single rule string
      windowrule = [
        # Per-game tearing opt-in (general.allow_tearing only enables
        # the capability; `immediate` is what actually requests it).
        "match:class ^(steam_app_)(.*)$, immediate true"
        # Common floats.
        "match:class ^(pavucontrol)$, float true"
        "match:class ^(blueman-manager)$, float true"
        "match:class ^(nm-connection-editor)$, float true"
        "match:class ^(\\.?(file-roller|nautilus))$, float true"
        # Picture-in-Picture: float + pin so it stays visible while
        # workspace-hopping.
        "match:title ^(Picture-in-Picture)$, float true, pin true"
        # Keep the display awake while any window is fullscreen
        # (covers mpv, browsers, games, gamescope, OBS preview, ...).
        "match:class .*, idle_inhibit fullscreen"
      ];

      # ---- Keybinds --------------------------------------------------------
      bind =
        let
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
          "$mainMod, B, exec, $browser"

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

          # Passthrough mode: disable every Hyprland keybind until toggled
          # off again. Essential for KVM / nested compositors / remote
          # desktop where the guest needs the modifiers Hyprland is eating.
          "$mainMod, escape, submap, passthrough"
        ]
        ++ workspaceBinds;

      # Mouse-modifier bindings.
      bindm = [
        "$mainMod, mouse:272, movewindow" # left click + drag
        "$mainMod, mouse:273, resizewindow" # right click + drag
      ];

      # Repeating binds (held key fires repeatedly). Volume/brightness
      # are routed through swayosd-client for an on-screen indicator.
      binde = [
        ", XF86AudioRaiseVolume, exec, ${lib.getExe' pkgs.swayosd "swayosd-client"} --output-volume raise"
        ", XF86AudioLowerVolume, exec, ${lib.getExe' pkgs.swayosd "swayosd-client"} --output-volume lower"
      ];

      # Lock-safe binds (continue working while session is locked).
      bindl = [
        ", XF86AudioMute, exec, ${lib.getExe' pkgs.swayosd "swayosd-client"} --output-volume mute-toggle"
        ", XF86AudioMicMute, exec, ${lib.getExe' pkgs.swayosd "swayosd-client"} --input-volume mute-toggle"
        ", XF86AudioPlay, exec, playerctl play-pause"
        ", XF86AudioNext, exec, playerctl next"
        ", XF86AudioPrev, exec, playerctl previous"
      ];
    };

    # Submaps can't be expressed in the settings tree (they're a
    # statement, not a key-value pair). Declared in raw config so the
    # main binding list stays clean.
    extraConfig = ''
      submap = passthrough
      bind = SUPER, escape, submap, reset
      submap = reset
    '';
  };

  # ---------------------------------------------------------------------------
  # Lock / idle / wallpaper / clipboard / polkit — user systemd services.
  # ---------------------------------------------------------------------------

  programs.hyprlock.enable = true;

  services = {
    hypridle = {
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

    hyprpaper.enable = true;

    # Clipboard history daemon — stores everything wl-paste sees so the
    # Super+Shift+V keybind can pipe it through rofi.
    cliphist = {
      enable = true;
      allowImages = true;
    };

    # Polkit agent for GUI sudo prompts.
    hyprpolkitagent.enable = true;
  };

  # CLI tools the Hyprland keybinds call by bare name.
  home.packages = with pkgs; [
    grim # screenshot capture
    slurp # region select
    wl-clipboard # wl-copy / wl-paste
    cliphist # clipboard history CLI (daemon is the systemd service above)
    playerctl # media-key dispatch
  ];
}
