{ config, pkgs, ... }:
{
    environment.systemPackages = with pkgs; [
        # Communication
        telegram-desktop
        discord
        zoom-us
        mattermost-desktop
        element-desktop
        mailspring
    ];
}