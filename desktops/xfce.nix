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
        # X11 Programs
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
}