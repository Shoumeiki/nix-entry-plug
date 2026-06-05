{ config, pkgs, lib, ... }:
{
  sops.secrets."seafile/db-root-password"  = {};
  sops.secrets."seafile/admin-email"       = {};
  sops.secrets."seafile/admin-password"    = {};

  # Render secrets into an env file that docker compose reads at runtime.
  sops.templates."seafile-env" = {
    content = ''
      SEAFILE_DB_PASSWORD=${config.sops.placeholder."seafile/db-root-password"}
      SEAFILE_ADMIN_EMAIL=${config.sops.placeholder."seafile/admin-email"}
      SEAFILE_ADMIN_PASSWORD=${config.sops.placeholder."seafile/admin-password"}
    '';
    path = "/run/secrets-rendered/seafile.env";
    mode = "0400";
    restartUnits = [ "seafile.service" ];
  };

  environment.etc."seafile/docker-compose.yml" = {
    source = ../../docker/seafile/docker-compose.yml;
    mode = "0444";
  };

  systemd.services.seafile = {
    description = "Seafile cloud sync (Docker Compose)";
    after       = [ "docker.service" "network-online.target" ];
    wants       = [ "network-online.target" ];
    requires    = [ "docker.service" ];
    wantedBy    = [ "multi-user.target" ];

    serviceConfig = {
      Type             = "oneshot";
      RemainAfterExit  = true;
      WorkingDirectory = "/etc/seafile";
      EnvironmentFile  = "/run/secrets-rendered/seafile.env";
      ExecStart        = "${pkgs.docker}/bin/docker compose up -d --remove-orphans";
      ExecStop         = "${pkgs.docker}/bin/docker compose down";
      ExecReload       = "${pkgs.docker}/bin/docker compose pull && ${pkgs.docker}/bin/docker compose up -d --remove-orphans";
      Restart          = "on-failure";
      RestartSec       = "10s";
    };
  };


  networking.firewall.allowedTCPPorts = [ 8081 ];
}
