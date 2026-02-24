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
    programs.niri.enable = true;
    programs.niri.package = pkgs.niri-unstable;

    # Services
    services.udisks2.enable = true;
    services.gvfs.enable = true;
    services.tumbler.enable = true;
    services.gnome.gnome-keyring.enable = true;
    security.pam.services.greetd.enableGnomeKeyring = true;
    programs.dconf.enable = true;
    services.libinput.enable = true;

    xdg.portal = {
        enable = true;
        config.common.default = "*";
        extraPortals = with pkgs; [
            xdg-desktop-portal-gtk
        ];
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
        matugen

        # GTK themes (available for DMS dynamic theming)
        adw-gtk3
        tela-icon-theme
    ];

    environment.sessionVariables = {
        NIXOS_OZONE_WL = "1";
        ELECTRON_OZONE_PLATFORM_HINT = "auto";
        MOZ_ENABLE_WAYLAND = "1";
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
                ".config/matugen"
                ".config/niri"
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
