{ config, pkgs, lib, username, ... }:
{
  services.immich = {
    enable = true;
    host = "0.0.0.0";
    port = 2283;
    openFirewall = true;
  };

  # PostgreSQL is automatically configured by the Immich service
  # Redis is automatically configured by the Immich service

  # Setup service to create required Immich directories
  systemd.services.immich-setup = {
    description = "Initialize Immich storage directories";
    before = [ "immich-server.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      User = "immich";
      Group = "immich";
    };
    script = ''
      # Create required subdirectories
      mkdir -p /var/lib/immich/{upload,library,thumbs,profile,encoded-video,backups}

      # Create .immich marker files for integrity checks
      for dir in upload library thumbs profile encoded-video backups; do
        touch /var/lib/immich/$dir/.immich
      done

      echo "Immich storage directories initialized"
    '';
  };

  # Persist database data across reboots
  # Note: /var/lib/immich is mounted from vault drive (see hardware-configuration.nix)
  environment.persistence."/persist" = {
    directories = [
      "/var/lib/postgresql"
      "/var/lib/redis-immich"
    ];
  };
}
