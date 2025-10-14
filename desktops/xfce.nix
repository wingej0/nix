{ config, lib, pkgs, inputs, username, ... }:
{
    services.xserver = {
        enable = true;
        desktopManager = {
            xterm.enable = false;
            xfce.enable = true;
        };
        windowManager.qtile = {
            enable = true;
            extraPackages = python3Packages: with python3Packages; [
                qtile-extras
            ];
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

    # Enable flatpaks
    services.flatpak.enable = true;
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
        picom
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
        users.wingej0 = {
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
        home.file = {
            ".config/qtile".source = ./../home/configs/qtile;
            ".config/rofi".source = ./../home/configs/rofi;
            ".config/picom".source = ./../home/configs/picom;
        };
    };
}