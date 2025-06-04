{ config, pkgs, ... }:
{
    environment.systemPackages = with pkgs; [
        # Office
        anytype
        onlyoffice-bin
        evince
    ];
}