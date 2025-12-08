{ config, pkgs, username, ... }:
{
  # n8n workflow automation
  services.n8n = {
    enable = true;
    openFirewall = false; # We'll use nginx instead

    # Configure via environment variables
    environment = {
      # Database configuration
      DB_TYPE = "mongodb";

      # Network configuration
      N8N_HOST = "127.0.0.1";
      N8N_PORT = "5678";
      N8N_PROTOCOL = "https";

      # Webhook configuration for remote access
      WEBHOOK_URL = "https://${config.networking.hostName}.local:443";

      # Security - disable metrics endpoint
      N8N_METRICS = "false";
    };
  };

  # Service to generate MongoDB connection string before n8n starts
  systemd.services.n8n-db-setup = {
    description = "Generate n8n database connection file";
    wantedBy = [ "multi-user.target" ];
    before = [ "n8n.service" ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };

    script = ''
      # Generate environment file with MongoDB password at runtime
      PASSWORD=$(cat /persist/n8n_mongodb_password | tr -d '\n')
      mkdir -p /run/n8n
      echo "DB_MONGODB_CONNECTION_URL=mongodb://n8n:$PASSWORD@localhost:27017/n8n?authSource=n8n" > /run/n8n/db-env
      chmod 644 /run/n8n/db-env
    '';
  };

  # Create n8n user for the service
  users.users.n8n = {
    isSystemUser = true;
    group = "n8n";
    home = "/var/lib/n8n";
    createHome = true;
  };

  users.groups.n8n = {};

  # Configure n8n to use the environment file
  systemd.services.n8n = {
    requires = [ "n8n-db-setup.service" "mongodb.service" ];
    after = [ "n8n-db-setup.service" "mongodb.service" ];

    serviceConfig = {
      EnvironmentFile = pkgs.lib.mkForce "/run/n8n/db-env";
      DynamicUser = pkgs.lib.mkForce false;
      User = "n8n";
      Group = "n8n";
    };
  };

  # Nginx reverse proxy with HTTPS
  services.nginx = {
    enable = true;

    recommendedProxySettings = true;
    recommendedTlsSettings = true;

    virtualHosts."${config.networking.hostName}.local" = {
      forceSSL = true;
      sslCertificate = "/persist/ssl/${config.networking.hostName}.local.crt";
      sslCertificateKey = "/persist/ssl/${config.networking.hostName}.local.key";

      locations."/" = {
        proxyPass = "http://127.0.0.1:5678";
        proxyWebsockets = true;
        extraConfig = ''
          proxy_set_header Host $host;
          proxy_set_header X-Real-IP $remote_addr;
          proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
          proxy_set_header X-Forwarded-Proto $scheme;
        '';
      };
    };
  };

  # Open HTTPS port
  networking.firewall.allowedTCPPorts = [ 443 ];

  # Persistence for n8n data
  environment.persistence."/persist" = {
    directories = [
      { directory = "/var/lib/n8n"; user = "n8n"; group = "n8n"; mode = "0700"; }
    ];
  };

  # Script to generate self-signed certificate if it doesn't exist
  systemd.services.n8n-ssl-setup = {
    description = "Generate self-signed SSL certificate for n8n";
    wantedBy = [ "multi-user.target" ];
    before = [ "nginx.service" ];

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };

    script = ''
      CERT_DIR="/persist/ssl"
      CERT_FILE="$CERT_DIR/${config.networking.hostName}.local.crt"
      KEY_FILE="$CERT_DIR/${config.networking.hostName}.local.key"

      mkdir -p "$CERT_DIR"

      if [ ! -f "$CERT_FILE" ] || [ ! -f "$KEY_FILE" ]; then
        echo "Generating self-signed certificate for n8n..."
        ${pkgs.openssl}/bin/openssl req -x509 -nodes -days 3650 -newkey rsa:2048 \
          -keyout "$KEY_FILE" \
          -out "$CERT_FILE" \
          -subj "/C=US/ST=State/L=City/O=Organization/CN=${config.networking.hostName}.local"

        chmod 640 "$KEY_FILE"
        chgrp nginx "$KEY_FILE" 2>/dev/null || true
        chmod 644 "$CERT_FILE"
        echo "Certificate generated successfully!"
      else
        echo "SSL certificate already exists. Fixing permissions..."
        chmod 640 "$KEY_FILE"
        chgrp nginx "$KEY_FILE" 2>/dev/null || true
        chmod 644 "$CERT_FILE"
      fi
    '';
  };
}