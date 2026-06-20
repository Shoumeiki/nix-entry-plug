{ config, pkgs, ... }:
{
  # ---------------------------------------------------------------------------
  # User-installed applications.
  #
  # HM modules get used where they earn their keep (sensible defaults,
  # Stylix theming, shell integration). Everything else is just a package
  # in home.packages.
  #
  # System-level things live in modules/:
  #   - Steam, gamescope, gamemode, MangoHud, Heroic, Prism → modules/gaming/steam.nix
  #   - Thunar + plugins + gvfs/tumbler                     → modules/desktop/thunar.nix
  #   - Docker daemon                                        → modules/virtualisation/docker.nix
  #   - libvirtd / virt-manager / QEMU                       → modules/virtualisation/libvirt.nix
  # ---------------------------------------------------------------------------

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

    # OBS with the plugins needed for Wayland-native capture and clean
    # PipeWire audio routing.
    obs-studio = {
      enable = true;
      plugins = with pkgs.obs-studio-plugins; [
        wlrobs # wlroots / Hyprland screen capture
        obs-pipewire-audio-capture # per-app audio sources
      ];
    };
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
    tenacity # audio editor (Audacity fork)

    # ---- Notes / docs ----------------------------------------------------
    obsidian # PKM (unfree — in allowUnfreePredicate)
    libreoffice-fresh # office suite

    # ---- Media -----------------------------------------------------------
    imv # image viewer (Wayland-native)

    # ---- Dev tooling -----------------------------------------------------
    docker-compose # `docker compose` plugin
    openssh # ssh / scp / sftp client (also pulled in by programs.ssh)
  ];
}
