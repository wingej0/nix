{ config, pkgs, ... }:

{
  services.n8n = {
    enable = true;
    openFirewall = true; # Open port 5678 for n8n's web interface
    # You can add additional settings here as per n8n's environment variables
    # For example, to change the port:
    # settings = {
    #   port = 8080;
    # };
    # To configure the database (defaults to SQLite in /var/lib/n8n):
    # settings = {
    #   db = {
    #     client = "postgres"; # or "mysql"
    #     connection = {
    #       host = "localhost";
    #       port = 5432;
    #       database = "n8n";
    #       user = "n8nuser";
    #       password = "n8npassword";
    #     };
    #   };
    # };
  };
}