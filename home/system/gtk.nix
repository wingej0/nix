{ config, pkgs, ... }:
{
    dconf = {
        enable = true;
        settings = {
            "org/gnome/desktop/interface" = {
                color-scheme = "prefer-dark";
                cursor-theme = "Bibata-Modern-Classic";
            };
        };
    };
    gtk = {
        enable = true;

        cursorTheme = {
            name = "Bibata-Modern-Classic";
            package = pkgs.bibata-cursors;
            size = 24;
        };

        theme = {
            name = "Pop-dark";
            package = pkgs.pop-gtk-theme;
        };

        gtk3 = {
            extraConfig = {
                gtk-cursor-theme-name = "Bibata-Modern-Classic";
            };
        };
    };
}