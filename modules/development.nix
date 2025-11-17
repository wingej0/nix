{ config, pkgs, username, ... }:
{
    environment.systemPackages = with pkgs; [
        # Development
        vscode-fhs
        mongodb-compass
        insomnia
        unixODBC
        unixODBCDrivers.msodbcsql18
    ];

    environment.unixODBCDrivers = with pkgs.unixODBCDrivers; [ msodbcsql18 ];

    environment.persistence."/persist" = {
        users.${username} = {
            directories = [
                ".config/Code"
                ".config/MongoDB Compass"
                ".vscode"
            ];
        };
    };
}