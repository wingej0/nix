{ config, pkgs, inputs, username, ... }:
let
    pkgs-stable = import inputs.nixpkgs-stable {
        system = pkgs.system;
        config.allowUnfree = true;
    };
in
{
    environment.systemPackages = with pkgs; [
        # Media
        obs-studio
        mpv
        audacity
        gimp
        yt-dlp
        annotator
        ffmpeg
        loupe
        czkawka-full
        lollypop

        # From stable branch
        pkgs-stable.kdePackages.kdenlive
        pkgs-stable.handbrake
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