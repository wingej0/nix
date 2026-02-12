{ config, pkgs, username, ... }:
{
    nixpkgs.overlays = [
        (final: prev: {
            mailspring = prev.mailspring.overrideAttrs (oldAttrs: {
                postFixup = (oldAttrs.postFixup or "") + ''
                    wrapProgram $out/bin/mailspring \
                        --add-flags "--password-store=gnome-libsecret"
                '';
            });
        })
    ];

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