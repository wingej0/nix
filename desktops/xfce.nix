{ config, lib, pkgs, inputs, ... }:
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

    environment.systemPackages = with pkgs; [
        picom
        peek
        variety
        wallust
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
                ".config/picom"
                ".config/rofi"

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
}