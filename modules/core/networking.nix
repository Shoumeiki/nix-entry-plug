_: {
  # Hostname is set per-host in hosts/<host>/default.nix.
  networking = {
    networkmanager.enable = true;

    firewall = {
      enable = true;
      # SSH inbound during install/setup. Tighten or move behind WireGuard
      # / Tailscale later.
      allowedTCPPorts = [ 22 ];
    };
  };

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
    };
  };
}
