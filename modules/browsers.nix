{ config, pkgs, ... }:
{
    environment.systemPackages = with pkgs; [
        # Browsers
        google-chrome
        brave
    ];
}