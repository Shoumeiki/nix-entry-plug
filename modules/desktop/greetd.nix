{ pkgs, lib, ... }:
{
  # ---------------------------------------------------------------------------
  # greetd + ReGreet: minimal Wayland greeter.
  #
  # `programs.regreet.enable` wires up the full stack:
  #   - enables greetd
  #   - sets greetd's default session to launch ReGreet inside cage
  #     (a single-app Wayland kiosk)
  #   - exposes `programs.regreet.settings` for ReGreet config
  #
  # ReGreet is themed by Stylix's regreet target (autoEnable in stylix.nix).
  # If theming doesn't apply on the first real boot, set
  # `programs.regreet.settings.background` and friends here.
  # ---------------------------------------------------------------------------

  programs.regreet.enable = true;

  # ReGreet renders Stylix's wallpaper through GTK4's MediaFile widget,
  # which always pipes through GStreamer — even for static PNGs. The
  # greeter user has no plugin path in its default env, so GStreamer
  # logs a fatal-severity "missing decoder" message and glib's default
  # handler escalates to `abort()`. Result: regreet SIGABRTs ~2s after
  # launch, greetd cycles 5× and gives up with `start-limit-hit`.
  #
  # Inject GST_PLUGIN_SYSTEM_PATH_1_0 into greetd.service's Environment=
  # so cage → regreet → gst_play_main can all find decodebin and
  # pngdec. `base` provides decodebin / videoconvert / typefindfunctions;
  # `good` provides pngdec / jpegdec and the common LGPL codecs.
  #
  # Add `gst-plugins-bad` and `gst-libav` if you ever want video
  # wallpapers on the greeter; for a still PNG, base + good is enough.
  systemd.services.greetd.environment.GST_PLUGIN_SYSTEM_PATH_1_0 =
    lib.makeSearchPath "lib/gstreamer-1.0" (
      with pkgs.gst_all_1;
      [
        gst-plugins-base
        gst-plugins-good
      ]
    );
}
