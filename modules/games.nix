{ config, pkgs, username, ... }:
{
    environment.systemPackages = with pkgs; [
        stockfish
        lc0
    ];
}
