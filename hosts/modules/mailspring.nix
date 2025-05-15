{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    mailspring
  ];

}