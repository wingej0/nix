{ config, pkgs, username, ... }:
{
    environment.systemPackages = with pkgs; [
        # Communication
        telegram-desktop
        discord
        mattermost-desktop
        mailspring
        caprine
        zenity
    ];

    environment.persistence."/persist" = {
        users.${username} = {
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