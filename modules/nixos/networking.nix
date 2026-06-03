{ ... }:
{
  networking.networkmanager.enable = true;

  networking.nftables.enable = true;
  networking.firewall = {
    enable = true;
    allowPing = true;
  };

  # Optional VPN toggle (disabled by default)
  networking.mullvad.enable = false;
}
