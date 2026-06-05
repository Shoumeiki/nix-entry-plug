{ inputs, pkgs, ... }:
{
  programs.mpv = {
    enable = true;
    config = {
      profile = "gpu-hq";
      gpu-context = "wayland";
      hwdec = "auto-safe";     # AMD VAAPI hardware decode
      vo = "gpu";
      ao = "pipewire";
      sub-auto = "fuzzy";       # Load subtitles automatically
      sub-font = "Atkinson Hyperlegible";
      sub-font-size = 44;
      volume = 100;
      save-position-on-quit = true;
      keep-open = true;         # Stay open at end of file
      screenshot-format = "png";
      screenshot-directory = "~/Pictures/Screenshots";
    };
    bindings = {
      l = "seek 5";
      h = "seek -5";
      j = "seek -60";
      k = "seek 60";
      S = "cycle sub";
      A = "cycle audio";
      M = "cycle mute";
    };
  };

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      # Video
      "video/mp4"        = "mpv.desktop";
      "video/mkv"        = "mpv.desktop";
      "video/webm"       = "mpv.desktop";
      "video/x-matroska" = "mpv.desktop";
      "video/avi"        = "mpv.desktop";

      # Images
      "image/jpeg" = "imv.desktop";
      "image/png"  = "imv.desktop";
      "image/gif"  = "imv.desktop";
      "image/webp" = "imv.desktop";
      "image/svg+xml" = "imv.desktop";

      # PDF
      "application/pdf" = "org.pwmt.zathura.desktop";

      # Browser
      "text/html"             = "librewolf.desktop";
      "x-scheme-handler/http"  = "librewolf.desktop";
      "x-scheme-handler/https" = "librewolf.desktop";
    };
  };

  home.packages = with pkgs; [
    # Browsers
    librewolf
    inputs.helium-nix.packages.${pkgs.system}.default

    # Communication
    signal-desktop
    webcord

    # Productivity
    obsidian
    libreoffice
    zathura

    # Image
    imv
    krita
  ];
}
