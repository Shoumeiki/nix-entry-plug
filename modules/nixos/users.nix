{ config, ... }:
{
  sops.secrets."users/ellen/password" = {
    neededForUsers = true;
  };

  sops.secrets."users/guest/password" = {
    neededForUsers = true;
  };

  sops.secrets."ssh/ellen-authorized-keys" = { };

  users.users.ellen = {
    isNormalUser = true;
    description = "Ellen";
    extraGroups = [ "wheel" "docker" "video" "audio" ];
    hashedPasswordFile = config.sops.secrets."users/ellen/password".path;
    openssh.authorizedKeys.keyFiles = [
      config.sops.secrets."ssh/ellen-authorized-keys".path
    ];
  };

  users.users.guest = {
    isNormalUser = true;
    description = "Guest";
    extraGroups = [ "video" "audio" ];
    hashedPasswordFile = config.sops.secrets."users/guest/password".path;
  };

  security.sudo.wheelNeedsPassword = true;
}
