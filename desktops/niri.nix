{ config, lib, pkgs, inputs, username, ... }:
{
    imports = [
        inputs.niri.nixosModules.niri
    ];

    # Greeter — tuigreet via greetd (same as qtile)
    services.greetd = {
        enable = true;
        settings = {
            default_session = {
                command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --remember-user-session --sessions ${config.services.displayManager.sessionData.desktops}/share/wayland-sessions";
                user = "greeter";
            };
        };
    };

    # Prevent boot text artifacts on the greetd screen
    systemd.services.greetd.serviceConfig = {
        Type = "idle";
        StandardInput = "tty";
        StandardOutput = "tty";
        StandardError = "journal";
        TTYReset = true;
        TTYVHangup = true;
        TTYVTDisallocate = true;
    };

    # Niri compositor (unstable for include directive support, needed for DMS dynamic colors)
    nixpkgs.overlays = [ inputs.niri.overlays.niri ];
    programs.niri = {
        enable = true;
        package = pkgs.niri-unstable;
    };

    # Services
    services.upower.enable = true;
    services.udisks2.enable = true;
    services.gvfs.enable = true;
    services.tumbler.enable = true;
    services.gnome.gnome-keyring.enable = true;
    security.pam.services.greetd.enableGnomeKeyring = true;
    programs.dconf.enable = true;
    services.libinput.enable = true;

    xdg.portal = {
        enable = true;
        extraPortals = with pkgs; [ xdg-desktop-portal-gtk ];
        config.common = {
            default = [ "gtk" ];
            "org.freedesktop.impl.portal.ScreenCast" = [ "gnome" ];
            "org.freedesktop.impl.portal.Screenshot" = [ "gnome" ];
            "org.freedesktop.impl.portal.RemoteDesktop" = [ "gnome" ];
        };
    };

    environment.systemPackages = with pkgs; [
        pavucontrol
        xwayland-satellite-unstable

        # File Manager
        thunar
        ffmpegthumbnailer

        # DMS dependencies
        wl-clipboard
        cliphist

        # GTK themes (available for DMS dynamic theming)
        adw-gtk3
        tela-icon-theme
    ];

    environment.sessionVariables = {
        NIXOS_OZONE_WL = "1";
        ELECTRON_OZONE_PLATFORM_HINT = "auto";
        MOZ_ENABLE_WAYLAND = "1";
        QT_QPA_PLATFORMTHEME = "gtk3";
    };

    # Persistence
    environment.persistence."/persist" = {
        directories = [
            "/var/cache/tuigreet"
        ];
        users.${username} = {
            directories = [
                ".cache/DankMaterialShell"
                ".cache/thumbnails"
                ".config/DankMaterialShell"
                ".config/btop"
                ".config/matugen"
                ".config/niri"
                ".config/yazi"
                ".local/state/DankMaterialShell"
            ];
        };
    };

    # Home-manager: DMS + supporting config
    # Niri config is manual (~/.config/niri/config.kdl) for tinkering without rebuilds.
    # Once settings are dialed in, we'll move the config back to programs.niri.settings.
    home-manager.users.${username} = {
        imports = [
            inputs.dms.homeModules.dank-material-shell
            # inputs.dms.homeModules.niri  # Disabled — niri config is manual for now
            inputs.dms-plugin-registry.homeModules.default
        ];

        # GTK theming — DMS manages colors via dank-colors.css, we set base theme + preferences
        dconf.settings."org/gnome/desktop/interface" = {
            color-scheme = "prefer-dark";
            cursor-theme = "Bibata-Modern-Classic";
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
                name = "adw-gtk3";
                package = pkgs.adw-gtk3;
            };
            iconTheme = {
                name = "Tela";
                package = pkgs.tela-icon-theme;
            };
            gtk3.extraCss = ''@import url("dank-colors.css");'';
            gtk4.extraCss = ''@import url("dank-colors.css");'';
            gtk4.extraConfig.gtk-application-prefer-dark-theme = 1;
        };
        xdg.configFile."gtk-3.0/gtk.css".force = true;
        xdg.configFile."gtk-4.0/gtk.css".force = true;

        # Matugen user templates — btop + yazi color schemes generated on wallpaper change
        home.file.".config/matugen/config.toml".source = ../home/configs/matugen/config.toml;
        home.file.".config/matugen/templates/btop.theme".source = ../home/configs/matugen/templates/btop.theme;
        home.file.".config/matugen/templates/yazi-theme.toml".source = ../home/configs/matugen/templates/yazi-theme.toml;
        home.file.".config/matugen/templates/telegram.tdesktop-theme".source = ../home/configs/matugen/templates/telegram.tdesktop-theme;
        # btop — matugen generates ~/.config/btop/themes/dank-material.theme
        # Select it once via btop UI: Options (F2) > Color theme > dank-material

        # Anytype — redirect stdout/stderr to avoid EPIPE errors when launched from GUI
        # (Electron writes logs to stdout/stderr; without a terminal these are broken pipes,
        # causing EPIPE cascades that make startup appear to hang)
        # xdg.desktopEntries.anytype = {
        #     name = "Anytype";
        #     exec = "bash -c 'anytype %U </dev/null >/dev/null 2>&1'";
        #     icon = "anytype";
        #     comment = "P2P note-taking tool";
        #     categories = [ "Utility" "Office" "Calendar" "ProjectManagement" ];
        #     mimeType = [ "x-scheme-handler/anytype" ];
        # };

        # DankMaterialShell
        programs.dank-material-shell = {
            enable = true;
            systemd = {
                enable = true;
                restartIfChanged = true;
            };

            # Feature toggles
            enableSystemMonitoring = true;
            enableDynamicTheming = true;
            enableAudioWavelength = true;
            enableClipboardPaste = true;

            # Plugins
            plugins = {
                dankBatteryAlerts.enable = true;
                mediaPlayer = {
                    enable = true;
                    settings = {
                        preferredSource = "cider";
                    };
                };
            };
        };
};
}
