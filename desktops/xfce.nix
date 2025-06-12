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

        environment.systemPackages = with pkgs; [

                # X11 Programs
                picom
                flameshot
                peek
                variety
                wallust
                rofiak
                brightnessctl
                python3
            ];
        };
    };
}