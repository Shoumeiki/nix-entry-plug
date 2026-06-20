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
  };

  # Stylix doesn't currently manage icon themes directly. Install Papirus
  # system-wide so GTK / Qt icon-theme settings (configured per-user via
  # home-manager later) can resolve it.
  environment.systemPackages = [ pkgs.papirus-icon-theme ];
}
