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

  programs.gamemode.enable = true;

  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

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
