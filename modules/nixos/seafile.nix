{ config, pkgs, lib, ... }:
{
  # ---------------------------------------------------------------------------
  # Seafile self-hosted cloud sync
  # ---------------------------------------------------------------------------
  # Runs as two Docker containers (MariaDB + Seafile CE) managed by a
  # systemd service. Containers start on boot and restart on failure.
  #
  # Web UI:    http://localhost:8080  (local machine only)
  # Mobile:    Use the Seafile Android app, point it at your LAN IP:8080
  #            or set up a reverse proxy + domain for external access.
  #
  # First-run note: on the very first start, Seafile takes 30-60 seconds
  # to initialise the database. The UI will be unavailable until that
  # completes. Check logs with: docker compose -f /etc/seafile/docker-compose.yml logs -f
  # ---------------------------------------------------------------------------

  # ---------------------------------------------------------------------------
  # Secrets (add these values to secrets/secrets.yaml before rebuilding)
  # ---------------------------------------------------------------------------
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

  # ---------------------------------------------------------------------------
  # Deploy the compose file declaratively
  # ---------------------------------------------------------------------------
  environment.etc."seafile/docker-compose.yml" = {
    source = ../../docker/seafile/docker-compose.yml;
    mode = "0444";
  };

  # ---------------------------------------------------------------------------
  # Systemd service
  # ---------------------------------------------------------------------------
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

  # Open the Seafile port on the local firewall if you want LAN access.
  # For local-only use (localhost:8080) this is not needed.
  # networking.firewall.allowedTCPPorts = [ 8080 ];
}
