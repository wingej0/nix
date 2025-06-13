{ config, lib, pkgs, inputs, ... }:
{
    imports = [
        # (_: { nixpkgs.overlays = [ inputs.qtile-flake.overlays.default ]; })
        # ./../overlays/qtile-overlay.nix
    ];

    specialisation = {
        xfce-desktop.configuration = {

            services.xserver = {
                enable = true;   
                desktopManager = {
                    xterm.enable = false;
                xfce = {
                    enable = true;
                };
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
                flameshot
                peek
                variety
                wallust
                rofi
                brightnessctl
                python3
            ];
        };
    };
}