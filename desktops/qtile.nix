{ config, lib, pkgs, inputs, username, ... }:
{
    # Enable the X11 windowing system.
    services.xserver.enable = true;

    services.displayManager.sddm.enable = true;
    # services.xserver.windowManager.qtile = {
    #     enable = true;
    #     extraPackages = python3Packages: with python3Packages; [
    #         qtile-extras
    #     ];
    # };

    services.xserver.windowManager.qtile = {
      enable = true;
      package = inputs.qtile-flake.packages.${pkgs.stdenv.hostPlatform.system}.default;
      extraPackages = python3Packages:
        with python3Packages; [
          (qtile-extras.overridePythonAttrs (oldAttrs: {
            src = inputs.qtile-extras-flake.outPath;
            doCheck = false;
            propagatedBuildInputs =
              (oldAttrs.propagatedBuildInputs or [])
              ++ (with pkgs.python3Packages; [anyio]);
          }))
        ];
    };

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
        xfce.thunar

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

                # XFCE
                ".config/xfce4/xfconf"
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

        # Systemd user services for autostart
        systemd.user.services = {
            polkit-gnome = {
                Unit = {
                    Description = "PolicyKit Authentication Agent";
                    After = [ "graphical-session.target" ];
                    PartOf = [ "graphical-session.target" ];
                };
                Service = {
                    Type = "simple";
                    ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
                    Restart = "on-failure";
                    RestartSec = 1;
                };
                Install.WantedBy = [ "graphical-session.target" ];
            };

            system76-power-daemon = {
                Unit = {
                    Description = "System76 Power Management Daemon";
                    After = [ "graphical-session.target" ];
                    PartOf = [ "graphical-session.target" ];
                };
                Service = {
                    Type = "simple";
                    ExecStart = "${pkgs.system76-power}/bin/system76-power daemon";
                    Restart = "on-failure";
                };
                Install.WantedBy = [ "graphical-session.target" ];
            };

            variety = {
                Unit = {
                    Description = "Variety Wallpaper Manager";
                    After = [ "graphical-session.target" ];
                    PartOf = [ "graphical-session.target" ];
                };
                Service = {
                    Type = "simple";
                    ExecStartPre = "${pkgs.coreutils}/bin/cp ${config.users.users.${username}.home}/.dotfiles/home/configs/qtile/scripts/variety-wayland.sh ${config.users.users.${username}.home}/.config/variety/scripts/set_wallpaper";
                    ExecStart = "${pkgs.variety}/bin/variety";
                    Restart = "on-failure";
                };
                Install.WantedBy = [ "graphical-session.target" ];
            };

            cliphist-text = {
                Unit = {
                    Description = "Clipboard history daemon (text)";
                    After = [ "graphical-session.target" ];
                    PartOf = [ "graphical-session.target" ];
                };
                Service = {
                    Type = "simple";
                    ExecStart = "${pkgs.wl-clipboard}/bin/wl-paste --type text --watch ${pkgs.cliphist}/bin/cliphist store";
                    Restart = "on-failure";
                };
                Install.WantedBy = [ "graphical-session.target" ];
            };

            cliphist-image = {
                Unit = {
                    Description = "Clipboard history daemon (images)";
                    After = [ "graphical-session.target" ];
                    PartOf = [ "graphical-session.target" ];
                };
                Service = {
                    Type = "simple";
                    ExecStart = "${pkgs.wl-clipboard}/bin/wl-paste --type image --watch ${pkgs.cliphist}/bin/cliphist store";
                    Restart = "on-failure";
                };
                Install.WantedBy = [ "graphical-session.target" ];
            };

        };

        # Home Manager services
        services = {
            dunst.enable = true;

            swayidle = {
                enable = true;
                events = {
                    before-sleep = "${pkgs.swaylock-effects}/bin/swaylock -f";
                };
                timeouts = [
                    { timeout = 600; command = "${pkgs.swaylock-effects}/bin/swaylock -f"; }
                ];
            };
        };
    };
}
