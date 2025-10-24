{ config, pkgs, ... }:
{
    environment.systemPackages = with pkgs; [
        # Games
        gnome-2048
        scid-vs-pc
        stockfish
        lc0  
    ];

    environment.persistence."/persist" = {
        users.wingej0 = {
            directories = [
                ".scidvspc"
                ".local/share/gnome-2048"
            ];
        };
    };
}