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
    ];
}