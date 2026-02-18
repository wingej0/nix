# Configuration for dis-winget
{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # Networking
  networking.hostName = "dis-winget";
}
