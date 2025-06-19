{ config, pkgs, ... }:
{
    # Set up the database
    services.postgresql = {
        enable = true;
        package = pkgs.postgresql; 
  
        # Data directory for PostgreSQL
        dataDir = "/var/lib/postgresql/data"; 

        # Ensure specific databases exist on first activation
        ensureDatabases = [ 
            "n8n_db" # This will create a database named 'n8n_db'
        ];

        # Ensure specific roles (users) exist
        ensureUsers = [
            {
                name = "n8n_user"; # Username for n8n to connect with
            }
        ];

        initialScript = pkgs.writeText "n8n-db-init.sql" ''
            \set N8N_PASSWORD `cat /persist/n8n_db_password`

            -- Create/Update the user with the password
            ALTER USER n8n_user WITH PASSWORD :'N8N_PASSWORD';

            -- Grant all privileges on the n8n_db database to n8n_user
            GRANT ALL PRIVILEGES ON DATABASE n8n_db TO n8n_user;
            ALTER DEFAULT PRIVILEGES FOR ROLE n8n_user IN SCHEMA public GRANT ALL PRIVILEGES ON TABLES TO n8n_user;
            ALTER DEFAULT PRIVILEGES FOR ROLE n8n_user IN SCHEMA public GRANT ALL PRIVILEGES ON SEQUENCES TO n8n_user;
            ALTER DEFAULT PRIVILEGES FOR ROLE n8n_user IN SCHEMA public GRANT ALL PRIVILEGES ON FUNCTIONS TO n8n_user;
        '';

        # Authentication rules (pg_hba.conf)
        # This is crucial for controlling who can connect and how.
        # Use 'mkOverride 10' to ensure your custom rules take precedence.
        authentication = pkgs.lib.mkOverride 10 ''
            # TYPE  DATABASE        USER            ADDRESS                 METHOD
            local   all             all                                     peer
            host    all             all             127.0.0.1/32            md5
            host    all             all             ::1/128                 md5
            host    n8n_db          n8n_user        127.0.0.1/32            md5
        '';

        # Enable TCP/IP connections (if needed, e.g., for remote access or Docker/VMs)
        enableTCPIP = true;
        settings.port = 5432; # Default PostgreSQL port
  
    };

    # Enable n8n and connect it to the database
    services.n8n = {
        enable = true;
        settings = {
            N8N_USER_FOLDER = "/var/lib/n8n"; 
            DB_TYPE = "postgres";
            DB_POSTGRES_HOST = "localhost"; # Or the IP/hostname of your PostgreSQL server
            DB_POSTGRES_PORT = 5432;
            DB_POSTGRES_DATABASE = "n8n_db";
            DB_POSTGRES_USER = "n8n_user";
            DB_POSTGRES_PASSWORD_FILE = "/persist/n8n_db_password"; # Matches the path in PostgreSQL config
        };
        # ... other n8n settings
    };

}