{ config, lib, pkgs, inputs, username, ... }:
{
    # Enable the X11 windowing system.
    services.xserver.enable = true;

    services.displayManager.sddm = {
        enable = true;
    };
    services.xserver.windowManager.qtile = {
        enable = true;
        extraPackages = python3Packages: with python3Packages; [
            qtile-extras
        ];
    };

    # services.xserver.windowManager.qtile = {
    #   enable = true;
    #   package = inputs.qtile-flake.packages.${pkgs.stdenv.hostPlatform.system}.default;
    #   extraPackages = python3Packages:
    #     with python3Packages; [
    #       (qtile-extras.overridePythonAttrs (oldAttrs: {
    #         src = inputs.qtile-extras-flake.outPath;
    #         doCheck = false;
    #         propagatedBuildInputs =
    #           (oldAttrs.propagatedBuildInputs or [])
    #           ++ (with pkgs.python3Packages; [anyio]);
    #       }))
    #     ];
    # };

    hardware.bluetooth.enable = true;
    services.udisks2.enable = true;
    services.gvfs.enable = true;

    environment.systemPackages = with pkgs; [
        pavucontrol
        python3 # Needed for update widget

        # Portals
        xdg-desktop-portal
        xdg-desktop-portal-wlr
        xdg-desktop-portal-gtk

        # File Manager
        thunar

        # Wayland Programs
        rofi
        grim
        slurp
        swappy
        wf-recorder
        zenity
        wl-clipboard
        cliphist
        swayidle
        swaylock-effects
        polkit_gnome
        wlogout
        ffmpeg
        wlr-randr
        dunst
        playerctl
        brightnessctl
        xwayland
        nwg-look
    ];

    programs.xwayland.enable = true;
    programs.dconf.enable = true;
    services.libinput.enable = true;

    xdg.portal = {
        enable = true;
        config.common.default = "*";
        extraPortals = with pkgs; [
            xdg-desktop-portal-wlr
            xdg-desktop-portal-gtk
        ];
    };

    # Polkit authentication agent
    systemd.user.services.polkit-gnome-authentication-agent-1 = {
        description = "polkit-gnome-authentication-agent-1";
        wantedBy = [ "graphical-session.target" ];
        wants = [ "graphical-session.target" ];
        after = [ "graphical-session.target" ];
        serviceConfig = {
            Type = "simple";
            ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
            Restart = "on-failure";
            RestartSec = 1;
            TimeoutStopSec = 10;
        };
    };

    services.gnome.gnome-keyring.enable = true;
    security.pam.services.sddm.enableGnomeKeyring = true;

    # Enable pam for swaylock, so it will actually unlock
    security.pam.services.swaylock = {};

    environment.sessionVariables = {
        NIXOS_OZONE_WL = "1";
        QT_QPA_PLATFORMTHEME = "qt5ct";
    };

    # Persistence
    environment.persistence."/persist" = {
        users.${username} = {
            directories = [
                # Qtile
                ".local/share/qtile"
                
                # wallust template files
                ".cache/qtile"
                ".cache/rofi"
                ".cache/wlogout"
            ];
        };
    };

    # Config files
    home-manager.users.${username} = {
        home.file = {
            ".config/dunst".source = ./../home/configs/dunst;
            ".config/qtile".source = ./../home/configs/qtile;
            ".config/rofi".source = ./../home/configs/rofi;
            ".config/swappy".source = ./../home/configs/swappy;
            ".config/swaylock".source = ./../home/configs/swaylock;
            ".config/wlogout".source = ./../home/configs/wlogout;
        };
        home.pointerCursor = {
            gtk.enable = true;
            x11.enable = true;
            package = pkgs.bibata-cursors;
            name = "Bibata-Modern-Classic";
            size = 24;
        };
    };
}
