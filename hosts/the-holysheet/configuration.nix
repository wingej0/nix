# Configuration for the-holysheet
{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./cron.nix
  ];

  # Networking
  networking.hostName = "the-holysheet";
}
