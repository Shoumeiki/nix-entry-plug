{ ... }:
{
  networking.networkmanager.enable = true;

  networking.nftables.enable = true;
  networking.firewall = {
    enable = true;
    allowPing = true;
  };

  services.openssh = {
    enable = true;
    openFirewall = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  # Optional VPN toggle (disabled by default)
  networking.mullvad.enable = false;
}
