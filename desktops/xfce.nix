{ config, lib, pkgs, inputs, username, ... }:
{
    services.xserver = {
        enable = true;

        windowManager.qtile = {
            enable = true;
            extraPackages = python3Packages: with python3Packages; [
                qtile-extras
            ];
        };

        desktopManager = {
            xterm.enable = false;
            xfce.enable = true;
            xfce.noDesktop = true;
            xfce.enableXfwm = false;
        };

        # windowManager.qtile = {
        #     enable = true;
        #     package = inputs.qtile-flake.packages.${pkgs.system}.default;
        #     extraPackages = python3Packages:
        #         with python3Packages; [
        #             (qtile-extras.overridePythonAttrs (oldAttrs: {
        #                 src = inputs.qtile-extras-flake.outPath;
        #             }))
        #         ];
        # };
    };

    services.displayManager.defaultSession = "xfce";
    services.gnome.gnome-keyring.enable = true;
    security.pam.services.lightdm.enableGnomeKeyring = true;

    services.blueman.enable = true;

    xdg.portal = {
        enable = true;
        config.common.default = "*";
        extraPortals = with pkgs; [
            xdg-desktop-portal-gtk
        ];
    };

    # Qtile specific packages
    environment.systemPackages = with pkgs; [
        peek
        rofi
        brightnessctl
        python3
        haskellPackages.greenclip
        file-roller
        playerctl
    ];

    # Persistence
    environment.persistence."/persist" = {
        users.${username} = {
            directories = [
                # Qtile
                ".local/share/qtile"
                
                # wallust template files
                ".cache/qtile"
                ".cache/rofi"

                # XFCE
                ".config/xfce4"
		        ".cache/sessions"
                ".config/autostart"
            ];
        };
    };

    # Config files
    home-manager.users.${username} = {
        xfconf.settings = {
            xfce4-session = {
                "general/SaveOnExit" = false;
                "sessions/Failsafe/IsFailsafe" = true;
                "sessions/Failsafe/Count" = 1;
                "sessions/Failsafe/Client0_Command" = [ "qtile" "start" ];
            };
        };
        
        home.file = {
            ".config/qtile".source = ./../home/configs/qtile;
            ".config/rofi".source = ./../home/configs/rofi;
            ".config/picom".source = ./../home/configs/picom;
        };

        services.picom = {
            enable = true;
            package = pkgs.picom;
            extraArgs = [ "--config" "/home/${username}/.config/picom/picom.conf" ];
        };

        systemd.user.services.greenclip = {
            Unit = {
                Description = "Greenclip clipboard manager daemon";
                After = [ "graphical-session-pre.target" ];
                PartOf = [ "graphical-session.target" ];
            };
            Service = {
                ExecStart = "${pkgs.haskellPackages.greenclip}/bin/greenclip daemon";
                Restart = "always";
            };
            Install = {
                WantedBy = [ "graphical-session.target" ];
            };
        };
    };
}
