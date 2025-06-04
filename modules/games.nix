{ config, pkgs, ... }:
{
    environment.systemPackages = with pkgs; [
        # Games
        gnome-2048
        scid-vs-pc
        stockfish
        lc0  
    ];
}