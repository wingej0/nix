{ config, lib, pkgs, inputs, ... }:
{
    # Enable the X11 windowing system.
    services.xserver.enable = true;

    # Enable Cinnamon
    services.xserver.displayManager.lightdm.enable = true;
    services.xserver.desktopManager.cinnamon.enable = true;

    services.gnome.gnome-keyring.enable = true;

    # Persistence
    environment.persistence."/persist" = {
        users.wingej0 = {
            directories = [
                # Cinnamon Desktop
                ".config/cinnamon"
                ".config/cinnamon-session"
                ".local/share/cinnamon"
            ];
        };
    };
}