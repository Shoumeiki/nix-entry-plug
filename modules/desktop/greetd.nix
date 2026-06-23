{ lib, pkgs, ... }:
let
  # Sway is used instead of cage because cage can't disable individual outputs
  # (nixpkgs#226586 — it spans all connected displays). Sway supports
  # `output * disable` / `output <name> enable`, which is exactly what we need.
  swayConfig = pkgs.writeText "greetd-sway-config" ''
    # Disable ALL outputs first, then enable only DP-1.
    # Targeting HDMI-A-1 by name alone is unreliable — if the name doesn't
    # match exactly at greeter time, sway silently ignores it and enables
    # everything. Disabling * first is the only robust approach.
    output * disable
    # Rose Pine Base (#191724) as the greeter background.  regreet's own
    # background.path option requires GStreamer at runtime and crashes in
    # the greeter environment; letting sway fill the colour is side-effect free.
    output DP-1 enable scale 1.33 background #191724 solid_color

    # Propagate Wayland vars so GTK4 / portals work inside regreet.
    exec dbus-update-activation-environment --systemd DISPLAY WAYLAND_DISPLAY SWAYSOCK

    exec "${lib.getExe pkgs.regreet}; ${lib.getExe' pkgs.sway "swaymsg"} exit"

    input type:keyboard {
      xkb_layout us
    }
  '';
in
{
  # `programs.regreet.enable` handles greetd, the config file, PAM, and the greeter
  # user. We override the session command (cage → sway) and give the greeter user a
  # writable home so sway's shader cache doesn't crash. Stylix's regreet target is off
  # (see stylix.nix — GStreamer crash); colours are applied manually via extraCss.
  programs.regreet = {
    enable = true;

    # Rose Pine Dark via extraCss (Stylix regreet target disabled — see above).
    # Adwaita base theme; the Rose Pine look comes entirely from extraCss below.
    theme = {
      name = "Adwaita";
      package = pkgs.gnome-themes-extra;
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    font = {
      name = "Inter";
      size = 16;
      package = pkgs.inter;
    };
    cursorTheme = {
      name = "Bibata-Modern-Classic";
      package = pkgs.bibata-cursors;
    };

    # Raw TOML settings not covered by the typed options above.
    # background.path is intentionally omitted: regreet's Picture widget
    # tries to initialise GStreamer (libgstplay) which isn't available in
    # the greeter environment and causes a crash.  The background colour
    # is set on the sway output above instead.
    settings.GTK = {
      application_prefer_dark_theme = true;
      cursor_theme_size = 24; # size is not a typed module option
    };

    # Rose Pine colour overrides on top of Adwaita-Dark.
    # GTK4 CSS: keep selectors broad; regreet's widget IDs are not stable.
    extraCss = ''
      /* ── Rose Pine base palette ── */
      window {
        background-color: #191724;
      }

      /* Login card */
      frame, .card {
        background-color: #1f1d2e;
        border: 1px solid #403d52;
        border-radius: 12px;
      }

      /* Text input fields */
      entry {
        background-color: #26233a;
        color: #e0def4;
        border-color: #403d52;
        caret-color: #c4a7e7;
      }
      entry:focus {
        border-color: #c4a7e7;
      }

      /* Sign-in button */
      button.suggested-action {
        background-color: #31748f;
        color: #e0def4;
      }
      button.suggested-action:hover {
        background-color: #3d8ba8;
      }

      /* Labels */
      label {
        color: #e0def4;
      }
      label.error {
        color: #eb6f92;
      }

      /* Session / user dropdowns */
      combobox button,
      menubutton > button {
        background-color: #26233a;
        color: #e0def4;
        border-color: #403d52;
      }
      popover.background {
        background-color: #1f1d2e;
        border: 1px solid #403d52;
      }
    '';
  };

  services.greetd.settings.default_session = lib.mkForce {
    command = "${lib.getExe pkgs.sway} --config ${swayConfig}";
    user = "greeter";
  };

  # Give the greeter user a real writable home so the GPU shader cache
  # (sway / Mesa) has somewhere to write. Without this sway logs:
  #   "Failed to create /var/empty/.cache — disabling shader cache"
  # and can crash or produce a blank screen.
  users.users.greeter = {
    home = "/var/lib/greetd";
    createHome = true;
  };
}
