{ config, pkgs, ... }:
{
    environment.systemPackages = with pkgs; [
        # Communication
        telegram-desktop
        discord
        # zoom-us ## Using flatpak version.  Nix package is buggy.
        mattermost-desktop
        mailspring
        caprine
        # element-desktop
    ];
}