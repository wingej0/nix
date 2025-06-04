{ config, pkgs, ... }:
{
    environment.systemPackages = with pkgs; [
        # Development
        vscode-fhs
        github-desktop
        jetbrains.pycharm-community
        mongodb-compass
        insomnia
        unixODBC
        unixODBCDrivers.msodbcsql18
    ];

    environment.unixODBCDrivers = with pkgs.unixODBCDrivers; [ msodbcsql18 ];
}