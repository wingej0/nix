{ config, pkgs, ... }:
{
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
        btop
        lshw
        bat
        system-config-printer
        oh-my-posh
        gearlever
        deja-dup
        inotify-tools
        variety
        wallust
        bitwarden-desktop
    ];
}
