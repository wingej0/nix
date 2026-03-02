{ config, lib, pkgs, username, inputs, ... }:
{
    imports = [
        ./../modules/cosmic-bg.nix
    ];
    
    # Enable Cosmic
    services.displayManager.cosmic-greeter.enable = true;
    services.desktopManager.cosmic.enable = true;
    services.system76-scheduler.enable = true;

    environment.sessionVariables.COSMIC_DATA_CONTROL_ENABLED = 1;

    # Environment variables
    environment.variables = {
        XCURSOR_SIZE=24;
        XCURSOR_THEME="Bibata-Modern-Classic";
    };

    environment.systemPackages = with pkgs; [
        variety
        wallust

        # cosmic
        cosmic-ext-tweaks
        inputs.cosmic-applets-collection.packages."${pkgs.system}".default
    ];

    home-manager.users.${username} = {
        imports = [ ./../home/system/gtk.nix ];

        programs.zsh.initContent = ''
            cat ~/.cache/wallust/sequences
        '';

        home.file.".config/variety/scripts/set_wallpaper" = {
            source = ./../home/configs/variety/set_wallpaper;
            executable = true;
        };

        home.file.".config/wallust".source = ./../home/configs/wallust;
    };

    # Persistence
    environment.persistence."/persist" = {
        users.${username} = {
            directories = [
                # Cosmic Desktop
                ".local/state/cosmic-comp"
                ".local/state/cosmic"
                ".config/cosmic"
            ];
            files = [
                ".config/cosmic-initial-setup-done"
            ];
        };
    };

}
