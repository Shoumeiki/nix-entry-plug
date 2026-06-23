{ pkgs, ... }:
{
  programs.steam = {
    enable = true;
    # Separate Wayland session launchable from the greeter. Boots straight
    # into the gamescope big-picture overlay — useful for sit-on-couch
    # gaming.
    gamescopeSession.enable = true;
    # Remote Play opens the LAN streaming ports automatically.
    remotePlay.openFirewall = true;
    # Local network game discovery (Source-engine titles, mostly).
    localNetworkGameTransfers.openFirewall = true;
    # Community Proton fork that tracks game-specific patches faster
    # than upstream Proton.
    extraCompatPackages = [ pkgs.proton-ge-bin ];
  };

  # CPU governor + IO scheduler tweaks while a gamemode-aware launcher
  # is running. Steam picks this up automatically; Heroic / Prism need
  # the user to wrap the game invocation in `gamemoderun`.
  programs.gamemode.enable = true;
}
