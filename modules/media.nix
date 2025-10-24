{ config, pkgs, ... }:
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
        vlc
        gnome-network-displays
    ];

    environment.persistence."/persist" = {
        users.wingej0 = {
            directories = [
                ".local/share/lollypop"
                ".cache/lollypop"
                ".config/obs-studio"
            ];
        };
    };
}