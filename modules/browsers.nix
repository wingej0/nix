{ config, pkgs, ... }:
{
    # Note: I have installed the Zen browser as a flatpak in flatpak.nix
    environment.systemPackages = with pkgs; [
        # Browsers
        google-chrome
        brave
    ];

    environment.persistence."/persist" = {
        users.wingej0 = {
            directories = [
                ".config/google-chrome"
                ".config/BraveSoftware"
            ];
        };
    };
}