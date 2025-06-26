{ config, lib, pkgs, username, ... }:
{
    imports = [
        ./../modules/cosmic-applets.nix
    ];

    
    # Enable xserver
    services.xserver.enable = true;

    # Enable Cosmic
    services.displayManager.cosmic-greeter.enable = true;
    services.desktopManager.cosmic.enable = true;

    environment.sessionVariables.COSMIC_DATA_CONTROL_ENABLED = 1;

    # Environment variables
    environment.variables = {
        XCURSOR_SIZE=24;
        XCURSOR_THEME="Bibata-Modern-Classic";
    };

    # Enable flatpaks
    services.flatpak.enable = true;

    environment.systemPackages = with pkgs; [
        # cosmic
        cosmic-ext-tweaks
    ];
}