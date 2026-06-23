{ config, pkgs, ... }:
{
  # HM modules used where they add value (sensible defaults, Stylix, shell integration).
  # Apps requiring root setup live in modules/ (gaming, thunar, gpu-screen-recorder, docker, libvirt).

  programs = {
    # TUI file manager. enableFishIntegration adds the `y` shell wrapper
    # that cds the parent shell into yazi's last-visited directory.
    yazi = {
      enable = true;
      enableFishIntegration = true;
    };

    # Video player. Stylix themes the OSC via stylix.targets.mpv.
    mpv.enable = true;

    # PDF viewer. Vim-style keybinds out of the box.
    zathura.enable = true;

    # MPD frontend.
    ncmpcpp.enable = true;
  };

  # MPD daemon (user-level). PipeWire output so it shares the same
  # routing graph as everything else.
  services.mpd = {
    enable = true;
    musicDirectory = "${config.home.homeDirectory}/Music";
    network.startWhenNeeded = true;
    extraConfig = ''
      audio_output {
        type "pipewire"
        name "PipeWire"
      }
    '';
  };

  home.packages = with pkgs; [
    # ---- Editors / IDEs --------------------------------------------------
    zed-editor

    # ---- Communication ---------------------------------------------------
    signal-desktop # encrypted messaging
    vesktop # Discord with Vencord patches (and proper screenshare on Wayland)

    # ---- Creative --------------------------------------------------------
    krita # digital painting
    audacity # audio editor

    # ---- Notes / docs ----------------------------------------------------
    obsidian # PKM (unfree — in allowUnfreePredicate)
    libreoffice-fresh # office suite

    # ---- Media -----------------------------------------------------------
    imv # image viewer (Wayland-native)

    # ---- Dev tooling -----------------------------------------------------
    docker-compose # `docker compose` plugin
  ];
}
