{ pkgs, ... }:
{
  # -------------------------------------------------------------------------
  # Steam
  # Handles the Steam runtime, 32-bit libraries, and Proton automatically.
  # -------------------------------------------------------------------------
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = false;
    # Proton-GE alongside Valve's own Proton Experimental.
    # Managed with ProtonUp-Qt at runtime.
    extraCompatPackages = with pkgs; [
      proton-ge-bin
    ];
  };

  # -------------------------------------------------------------------------
  # GameMode
  # Switches CPU governor to performance and adjusts I/O priority for the
  # duration of a game session, then reverts on exit.
  # -------------------------------------------------------------------------
  programs.gamemode.enable = true;

  # -------------------------------------------------------------------------
  # GPU / graphics
  # AMD RX 7700 XT uses RADV (Mesa's Vulkan driver) by default.
  # enable32Bit is required for Proton and 32-bit game compatibility.
  # -------------------------------------------------------------------------
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # -------------------------------------------------------------------------
  # Gaming tools
  # -------------------------------------------------------------------------
  environment.systemPackages = with pkgs; [
    # Overlay: FPS, frame times, temps, GPU/CPU load
    mangohud

    # Valve's nested micro-compositor for resolution scaling, FSR, VRR
    gamescope

    # GUI manager for Proton-GE versions
    protonup-qt

    # Epic/GOG launcher
    heroic

    # Minecraft launcher
    prismlauncher

    # Controller: xpadneo for Xbox/8BitDo Bluetooth controllers
    # xpadneo
  ];
}
