{ config, pkgs, ... }:
{
    environment.systemPackages = with pkgs; [
        # Communication
        telegram-desktop
        discord
        mattermost-desktop
        mailspring
        caprine
    ];

    environment.persistence."/persist" = {
        users.wingej0 = {
            directories = [
                ".local/share/TelegramDesktop"
                ".config/discord"
                ".config/Mattermost"
                ".config/Mailspring"
                ".config/Caprine"
            ];
        };
    };
}