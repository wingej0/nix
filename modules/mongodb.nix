{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    mongodb
    mongosh
  ];

  # Enable mongodb
  services.mongodb = {
    enable = true;
    enableAuth = true;
    initialRootPassword = "mongodbroot";
    bind_ip = "0.0.0.0";
  };
}