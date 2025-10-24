{ config, lib, pkgs, username, inputs, ... }:
{
    imports = [
        # Apply the overlay here
        # ({
        #   nixpkgs.overlays = [ inputs.cosmic-nightly.overlays.default ];
        # })
    ];

    
    # Enable xserver
    services.xserver.enable = true;

    # Enable Cosmic
    services.displayManager.cosmic-greeter.enable = true;
    services.desktopManager.cosmic.enable = true;

    environment.sessionVariables.COSMIC_DATA_CONTROL_ENABLED = 1;

    # Environment variables
    environment.variables = {
        XCURSOR_SIZE=24;
        XCURSOR_THEME="Bibata-Modern-Classic";
    };

    environment.systemPackages = with pkgs; [
        # cosmic
        cosmic-ext-tweaks
        inputs.cosmic-applets-collection.packages."${system}".default
    ];

    # Persistence
    environment.persistence."/persist" = {
        users.wingej0 = {
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
