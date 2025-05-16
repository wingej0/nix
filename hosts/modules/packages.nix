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
        
        vscode-fhs
        anytype
    ];
}