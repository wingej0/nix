{ config, lib, pkgs, ... }:
{
    
    # Enable the X11 windowing system.
    services.xserver.enable = true;

    # Enable Cinnamon
    services.xserver.displayManager.lightdm.enable = true;
    services.xserver.desktopManager.cinnamon.enable = true;

    # Enable flatpaks
    services.flatpak.enable = true;
        
}