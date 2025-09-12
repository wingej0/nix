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

        font = {
            name = "Fira Code Nerd Font";
            size = 11;
        };

        theme = {
            name = "Pop";
            package = pkgs.pop-gtk-theme;
        };

        iconTheme = {
            name = "Pop";
            package = pkgs.pop-icon-theme;
        };

        gtk3 = {
            extraConfig = {
                gtk-cursor-theme-name = "Bibata-Modern-Classic";
            };
        };

        gtk4 = {
            extraConfig = {
                gtk-application-prefer-dark-theme = 1;
            };
        };
    };
}