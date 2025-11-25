{ config, lib, pkgs, inputs, username, ... }:
{
    services.displayManager.sddm.enable = true;
    services.displayManager.sddm.wayland.enable = true;
    services.desktopManager.plasma6.enable = true;

    # Enable gnome-keyring for applications like Mailspring and MongoDB Compass
    services.gnome.gnome-keyring.enable = true;
    security.pam.services.sddm.enableGnomeKeyring = true;

    # Ensure keyring packages are available
    environment.systemPackages = with pkgs; [
        gnome-keyring
        libsecret
    ];

}