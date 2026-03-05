{ config, pkgs, username, ... }:
{
    environment.systemPackages = with pkgs; [
        vscode-fhs
        
        # Development
        unixODBC
        unixODBCDrivers.msodbcsql18
        nodejs
        jq
    ];

    environment.persistence."/persist" = {
        users.${username} = {
            directories = [
                ".config/Code"
                ".vscode"
            ];
        };
    };

    environment.unixODBCDrivers = with pkgs.unixODBCDrivers; [ msodbcsql18 ];
}
