{ config, lib, pkgs, ... }:
{
    imports = [
        ./../modules/cosmic-applets.nix
    ];

    specialisation = {
        cosmic-desktop.configuration = {
            # Enable xserver
            services.xserver.enable = true;

            # Enable Cosmic
            services.displayManager.cosmic-greeter.enable = true;
            services.desktopManager.cosmic.enable = true;

            environment.sessionVariables.COSMIC_DATA_CONTROL_ENABLED = 1;

            # Enable flatpaks
            services.flatpak.enable = true;

            environment.systemPackages = with pkgs; [
                # cosmic
                cosmic-ext-tweaks
                papirus-maia-icon-theme
                papirus-folders
            ];
        };
    };
}