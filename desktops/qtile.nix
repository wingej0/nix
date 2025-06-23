{ config, lib, pkgs, inputs, ... }:
{
    imports = [
        (_: { nixpkgs.overlays = [ inputs.qtile-flake.overlays.default ]; })
        ./../overlays/qtile-overlay.nix
    ];

    
    # Enable the X11 windowing system.
    services.xserver.enable = true;

    # Enable Qtile
    services.displayManager.sddm.enable = true;
    services.xserver.windowManager.qtile = {
        enable = true;
        extraPackages = python3Packages: with python3Packages; [
            qtile-extras
        ];
    };

    services.gnome.gnome-keyring.enable = true;
    programs.xwayland.enable = true;

    environment.sessionVariables = {
        WLR_NO_HARDWARE_CURSORS = 1;
        NIXOS_OZONE_WL = "1";
        MOZ_ENABLE_WAYLAND = 1;
        ELECTRON_OZONE_PLATFORM_HINT = 1;
    };

    # Enable flatpaks
    services.flatpak.enable = true;
    services.blueman.enable = true;

    xdg.portal = {
        enable = true;
        config.common.default = "*";
        extraPortals = with pkgs; [
            xdg-desktop-portal-wlr
            xdg-desktop-portal-gtk
        ];
    };

    environment.systemPackages = with pkgs; [

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

    ];

}
