{ config, pkgs, ... }:
{
    programs.firefox.enable = true;

    environment.systemPackages = with pkgs; [
        # System Packages
        zsh
        git
        gh
        wget
        vim
        htop
        acpi
        killall
        fzf
        fastfetch
        veracrypt
        remmina
        popsicle
        gparted
        bibata-cursors
        eza
        yazi
        htop
        lshw
        bat
        system-config-printer
        github-desktop
        
        # Browsers
        google-chrome
        brave

        # Communication
        telegram-desktop
        caprine-bin
        discord
        zoom-us
        mattermost-desktop
        element-desktop
        mailspring

        # Games
        gnome-2048
        scid-vs-pc
        stockfish
        lc0  

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
        
        vscode-fhs

        # Office
        anytype
        onlyoffice-bin
        evince

        # cosmic
        cosmic-ext-tweaks
    ];
}