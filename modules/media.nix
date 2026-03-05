{ config, pkgs, inputs, username, ... }:
{
    environment.systemPackages = with pkgs; [
        # Media
        yt-dlp
        ffmpeg
        annotator
    ];
}
