{ config, pkgs, ... }:
{
    environment.systemPackages = with pkgs; [
        # cosmic
        cosmic-ext-tweaks
        papirus-maia-icon-theme
        papirus-folders
    ];
}