{ config, pkgs, username, ... }:
{
  environment.systemPackages = with pkgs; [
    mongosh
  ];

  # Enable mongodb
  services.mongodb = {
    enable = true;
    package = pkgs.mongodb-ce;
    enableAuth = true;
    initialRootPasswordFile = "/persist/mongodb_password";
    bind_ip = "0.0.0.0";
  };

  environment.persistence."/persist" = {
        directories = [
            "/var/db"
        ];
        users.${username} = {
            directories = [
                ".mongodb"
            ];
        };
    };
}