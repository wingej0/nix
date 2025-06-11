{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    mongodb-ce
    mongosh
  ];

  # Enable mongodb
  services.mongodb = {
    enable = true;
    enableAuth = true;
    initialRootPasswordFile = "/home/wingej0/.mongodb_root";
    bind_ip = "0.0.0.0";
  };
}