{ inputs, pkgs, ... }:
{
  # autoEnable = true (default) themes every supported target automatically.
  # Opt specific targets out via `stylix.targets.<name>.enable = false`.
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

    targets.regreet.enable = false;
  };

}
