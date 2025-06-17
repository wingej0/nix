{ config, lib, pkgs, inputs, username, ... }:
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
                flameshot
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

        home-manager.users.${username} = {

            programs.zsh.initContent = ''
                cat ~/.cache/wallust/sequences
            '';

            gtk = {
                enable = true;
    
                gtk3 = {
                    extraConfig = {
                        gtk-application-prefer-dark-theme = 1;
                    };
                };

                gtk4 = {
                    extraConfig = {
                        gtk-application-prefer-dark-theme = 1;
                    };
                };

                font = {
                    name = "Fira Code Nerd Font";
                    size = 11;
                };

                theme = {
                    name = "Orchis";
                    package = pkgs.orchis-theme;
                };

                iconTheme = {
                    name = "Tela-dark";
                    package = pkgs.tela-icon-theme;
                };
            };
        };
    };
 
    };
}