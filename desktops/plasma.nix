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

    # Persist KDE Plasma 6 configuration and state
    environment.persistence."/persist".users.${username}.directories = [
        ".config/kdedefaults"
        ".config/plasma-workspace"
        ".config/plasmashellrc"
        ".config/plasmarc"
        ".config/kdeglobals"
        ".config/kwinrc"
        ".config/kglobalshortcutsrc"
        ".config/systemsettingsrc"
        ".config/kscreenlockerrc"
        ".config/kcminputrc"
        ".config/khotkeysrc"
        ".config/ksmserverrc"
        ".config/Trolltech.conf"
        ".local/share/plasma"
        ".local/share/kwalletd"
        ".local/share/kactivitymanagerd"
        ".local/share/kscreen"
        ".local/share/baloo"
        ".local/share/dolphin"
        ".local/share/konsole"
        ".cache/plasma"
    ];

}