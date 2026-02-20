{ config, pkgs, username, ... }:
{
    nixpkgs.overlays = [
        (final: prev: {
            mailspring = prev.mailspring.overrideAttrs (oldAttrs: {
                nativeBuildInputs = (oldAttrs.nativeBuildInputs or [ ]) ++ [ final.makeWrapper ];
                postFixup = (oldAttrs.postFixup or "") + ''
                    wrapProgram $out/bin/mailspring \
                        --prefix PATH : ${final.lib.makeBinPath [ final.zenity final.libnotify ]} \
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