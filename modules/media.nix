{ config, pkgs, username, ... }:
{
    environment.systemPackages = with pkgs; [
        # Media
        obs-studio
        kdePackages.kdenlive
        mpv
        audacity
        gimp
        yt-dlp
        annotator
        ffmpeg
        loupe
        czkawka-full
        lollypop
        handbrake
    ];

    environment.persistence."/persist" = {
        users.${username} = {
            directories = [
                ".local/share/lollypop"
                ".cache/lollypop"
                ".config/obs-studio"
            ];
        };
    };
}