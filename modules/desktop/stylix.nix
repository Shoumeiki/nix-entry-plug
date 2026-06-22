{ inputs, pkgs, ... }:
{
  # ---------------------------------------------------------------------------
  # Stylix: unified system-wide theming.
  #
  # autoEnable = true (default) lets Stylix theme every supported target it
  # finds — Hyprland, hyprpaper, hyprlock, waybar, mako, foot, kitty, GTK,
  # Qt, ReGreet, bat, fish, starship, etc. — without per-target plumbing.
  # Disable individual targets via `stylix.targets.<name>.enable = false`
  # if any one needs to opt out.
  # ---------------------------------------------------------------------------

  imports = [ inputs.stylix.nixosModules.stylix ];

  stylix = {
    enable = true;
    polarity = "dark";

    # Rosé Pine base16 yaml ships with the base16-schemes package. Swap
    # the filename for a custom scheme path when the personal palette
    # lands (see Future Phases → Custom colour theme).
    base16Scheme = "${pkgs.base16-schemes}/share/themes/rose-pine.yaml";

    # Placeholder wallpaper from nixos-artwork until a real one lands.
    # `gnomeFilePath` is the canonical string path to the .png inside the
    # derivation, suitable for Stylix's `image` option.
    image = pkgs.nixos-artwork.wallpapers.nineish-dark-gray.gnomeFilePath;

    fonts = {
      monospace = {
        package = pkgs.nerd-fonts.jetbrains-mono;
        name = "JetBrainsMono Nerd Font";
      };
      sansSerif = {
        package = pkgs.inter;
        name = "Inter";
      };
      serif = {
        package = pkgs.merriweather;
        name = "Merriweather";
      };
      emoji = {
        package = pkgs.noto-fonts-color-emoji;
        name = "Noto Color Emoji";
      };
    };

    cursor = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Classic";
      size = 24;
    };

    # Theme the TTY palette too — useful when a graphical session fails
    # and you're back on the bare console.
    targets.console.enable = true;

    # ReGreet (the greetd greeter) MUST be opted out.
    #
    # Stylix's regreet target writes /etc/greetd/regreet.toml with a
    # `[background]` section pointing at `stylix.image` (a PNG). ReGreet
    # 0.4.0 hands that path to GTK4's `gtk_media_file_new_for_filename`,
    # which always routes through GStreamer (even for stills). The
    # greeter user has no GStreamer plugin path → GStreamer logs a
    # fatal-severity "missing decoder" → glib's default log handler
    # escalates to `abort()`. ReGreet SIGABRTs ~2s into launch, greetd
    # retries 5×, hits `start-limit-hit`, and the system is left at a
    # console with no display manager.
    #
    # Coredump signature (regreet 0.4.0 + gtk4 + missing gst plugins):
    #   gst_play_main → g_log → _g_log_abort.cold → abort
    #
    # Workarounds exist (pull gst-plugins-base/good into the greeter's
    # PATH, or pin regreet < 0.4) but disabling the Stylix-managed
    # config is the cheapest and the greeter is rarely seen anyway.
    # Cursor/font/theme stylings live on the user's actual Hyprland
    # session; only the greeter loses theming.
    targets.regreet.enable = false;
  };

  # Stylix doesn't currently manage icon themes directly. Install Papirus
  # system-wide so GTK / Qt icon-theme settings (configured per-user via
  # home-manager later) can resolve it.
  environment.systemPackages = [ pkgs.papirus-icon-theme ];
}
