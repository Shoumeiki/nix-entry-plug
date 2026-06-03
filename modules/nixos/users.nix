{ ... }:
{
  users.users.ellen = {
    isNormalUser = true;
    description = "Ellen";
    extraGroups = [ "wheel" "docker" "video" "audio" ];

    # Password hash should be sourced via sops-nix secret after setup.
    # hashedPasswordFile = config.sops.secrets."users/ellen/password".path;
  };

  users.users.guest = {
    isNormalUser = true;
    description = "Guest";
    extraGroups = [ "video" "audio" ];
  };

  security.sudo.wheelNeedsPassword = true;
}
