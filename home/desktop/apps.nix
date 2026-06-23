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
    signal-desktop
    vesktop # Discord with Vencord patches (proper Wayland screenshare)

    # ---- Creative --------------------------------------------------------
    krita
    audacity

    # ---- Notes / docs ----------------------------------------------------
    obsidian # unfree — in allowUnfreePredicate
    libreoffice-fresh

    # ---- Media -----------------------------------------------------------
    imv # Wayland-native image viewer

    # ---- Gaming ----------------------------------------------------------
    mangohud # in-game perf overlay (used with gamemoderun)
    heroic # Epic / GOG / Amazon launcher
    prismlauncher # Minecraft launcher

    # ---- Desktop utilities -----------------------------------------------
    gpu-screen-recorder-gtk # GUI for the system-level gpu-screen-recorder
    lm_sensors # `sensors` binary used by the waybar gpu-temp module
    bluez-tools # Bluetooth CLI management
    papirus-icon-theme # icon theme for GTK apps in the user session

    # ---- Dev tooling -----------------------------------------------------
    docker-compose
  ];
}
