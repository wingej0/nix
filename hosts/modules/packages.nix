{ config, pkgs, ... }:
{
    programs.firefox.enable = true;

    environment.systemPackages = with pkgs; [
        vim
        wget
        git
        gh
        vscode-fhs
        mailspring
        anytype
    ];
}