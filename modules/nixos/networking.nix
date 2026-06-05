{ ... }:
{
  networking.networkmanager.enable = true;

  # -------------------------------------------------------------------------
  # Firewall (nftables, default-deny inbound)
  # -------------------------------------------------------------------------
  networking.nftables.enable = true;
  networking.firewall = {
    enable = true;
    allowPing = true;
    # Add ports here as needed, e.g.:
    # allowedTCPPorts = [ 80 443 ];
  };

  # -------------------------------------------------------------------------
  # SSH (key-auth only; password auth disabled)
  # -------------------------------------------------------------------------
  services.openssh = {
    enable = true;
    openFirewall = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  # -------------------------------------------------------------------------
  # Mullvad VPN (toggle-able; disabled by default)
  # To enable: set networking.mullvad.enable = true
  # and add your account token to secrets.yaml.
  # -------------------------------------------------------------------------
  networking.mullvad.enable = false;
}
