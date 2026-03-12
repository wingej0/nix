{ config, pkgs, inputs, username, ... }:
{
    imports = [
        inputs.nix-flatpak.nixosModules.nix-flatpak
    ];

    # Enable flatpak service (required for nix-flatpak)
    services.flatpak.enable = true;

    # Enable remote repos
    services.flatpak.remotes = [
        {
            name = "flathub";
            location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
        }
    ];

    # Install flatpaks declaratively
    services.flatpak = {
        packages = [
            # System
            "us.zoom.Zoom"
            "org.gnome.NetworkDisplays"

            # Browsers
            "com.google.Chrome"
            "com.brave.Browser"
            "app.zen_browser.zen"

            # Communication
            "org.telegram.desktop"
            "com.discordapp.Discord"
            "com.mattermost.Desktop"
            "com.sindresorhus.Caprine"
            "eu.betterbird.Betterbird"

            # Office
            "io.anytype.anytype"
            "org.onlyoffice.desktopeditors"
            "org.gnome.Evince"
            "org.gnome.gitlab.somas.Apostrophe"

            # Media
            "com.obsproject.Studio"
            "io.mpv.Mpv"
            "org.audacityteam.Audacity"
            "org.gimp.GIMP"
            "org.kde.kdenlive"
            "fr.handbrake.ghb"
            "org.gnome.Loupe"
            "org.gnome.Lollypop"
            "com.github.qarmin.czkawka"
            "org.inkscape.Inkscape"

            # Development
            "com.mongodb.Compass"
            "rest.insomnia.Insomnia"
            "org.gnome.TextEditor"

            # Games
            "org.gnome.TwentyFortyEight"
            "io.github.whelanh.scidCommunity"

            # System Utilities
            "com.github.tchx84.Flatseal"
            "org.remmina.Remmina"
            "com.system76.Popsicle"
            "org.gnome.World.PikaBackup"
            "com.bitwarden.desktop"
            "com.borgbase.Vorta"
        ];
    };

    # Global overrides: give all flatpaks access to cursor and GTK themes
    services.flatpak.overrides.global = {
        Context.filesystems = [
            "/run/current-system/sw/share/themes:ro"
            "/run/current-system/sw/share/icons:ro"
            "~/.themes:ro"
            "~/.icons:ro"
            "~/.local/share/themes:ro"
            "~/.local/share/icons:ro"
        ];
        Environment = {
            XCURSOR_THEME = "Bibata-Modern-Classic";
            XCURSOR_SIZE = "24";
        };
    };

    # Per-app overrides
    services.flatpak.overrides."eu.betterbird.Betterbird" = {
        Context.filesystems = [ "xdg-documents" "xdg-pictures" "xdg-desktop" ];
    };

    # Firewall rules for gnome-network-displays (WiFi Display/Miracast)
    networking.firewall.allowedTCPPorts = [ 7236 7250 ];
    networking.firewall.allowedUDPPorts = [ 7236 ];

    # Persist any folders for flatpaks
    environment.persistence."/persist" = {
        users.${username} = {
            directories = [
                ".local/share/flatpak"

                # System
                ".var/app/us.zoom.Zoom"

                # Browsers
                ".var/app/com.google.Chrome"
                ".var/app/com.brave.Browser"
                ".var/app/app.zen_browser.zen"

                # Communication
                ".var/app/org.telegram.desktop"
                ".var/app/com.discordapp.Discord"
                ".var/app/com.mattermost.Desktop"
                ".var/app/com.sindresorhus.Caprine"
                ".var/app/eu.betterbird.Betterbird"

                # Office
                ".var/app/io.anytype.anytype"
                ".var/app/org.onlyoffice.desktopeditors"
                ".var/app/org.gnome.gitlab.somas.Apostrophe"
                "org.gnome.gitlab.somas.Apostrophe.Plugin.TexLive"

                # Media
                ".var/app/com.obsproject.Studio"
                ".var/app/org.gnome.Lollypop"
                ".var/app/org.gimp.GIMP"
                ".var/app/org.audacityteam.Audacity"
                ".var/app/org.inkscape.Inkscape"

                # Development
                ".var/app/com.mongodb.Compass"
                ".var/app/rest.insomnia.Insomnia"

                # Games
                ".var/app/io.github.whelanh.scidCommunity"

                # System Utilities
                ".var/app/com.bitwarden.desktop"
                ".var/app/org.remmina.Remmina"
                ".var/app/com.borgbase.Vorta"
            ];
        };
    };
}
