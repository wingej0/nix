{ config, pkgs, inputs, username, ... }:
{
    imports = [
        (_: { nixpkgs.overlays = [ inputs.qtile-flake.overlays.default ]; })
        ./../overlays/qtile-overlay.nix
    ];
    
    specialisation = {

        qtile-desktop.configuration = {
            # Enable the X11 windowing system.
            services.xserver.enable = true;
        
            # Enable Qtile
            services.displayManager.sddm.enable = true;
            services.xserver.windowManager.qtile = {
                package = inputs.qtile-flake.overlays.default;
                enable = true;
                extraPackages = python3Packages: with python3Packages; [
                    qtile-extras
                ];
            };

            hardware.bluetooth.enable = true;
            services.udisks2.enable = true;
            services.gvfs.enable = true;
            
            environment.systemPackages = with pkgs; [
                kitty
                xfce.thunar
                pavucontrol
                python3 # Needed for update widget
                variety
                wallust
		        lxappearance

                # Portals
                xdg-desktop-portal
                xdg-desktop-portal-wlr
                xdg-desktop-portal-gtk

                # Gnome stuff
                gnome-online-accounts
                gnome-calendar
                nautilus

                # Wayland Programs
                rofi-wayland
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

                # X11 Programs
                picom
                haskellPackages.greenclip
                numlockx
                flameshot
                betterlockscreen
                arandr
                peek
            ];

            programs.xwayland.enable = true;
            programs.dconf.enable = true;

            xdg.portal = {
                enable = true;
                config.common.default = "*";
                extraPortals = with pkgs; [
                    xdg-desktop-portal-wlr
                    xdg-desktop-portal-gtk
                ];
            };

            # Enable pam for swaylock, so it will actually unlock
            security.pam.services.swaylock = {};
            services.gnome.gnome-keyring.enable = true;

            environment.sessionVariables = {
                WLR_NO_HARDWARE_CURSORS = 1;
                NIXOS_OZONE_WL = 1;
                MOZ_ENABLE_WAYLAND = 1;
                ELECTRON_OZONE_PLATFORM_HINT = 1;
            };

            home-manager.users.${username} = {
                programs.zsh.initContent = ''
                    bindkey -e
                    fastfetch
                    export FZF_DEFAULT_OPTS="--layout reverse --border bold --border rounded --margin 3% --color dark"

                    # Set up fzf key bindings and fuzzy completion
                    source <(fzf --zsh)
                    bindkey -s '^e' 'vim $(fzf)\n'
                    cat ~/.cache/wallust/sequences

                    # oh-my-posh
                    eval "$(oh-my-posh init zsh --config ~/.config/ohmyposh/zen.toml)"
                '';
            };
        };
    };
}
