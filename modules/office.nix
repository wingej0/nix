{ config, pkgs, username, ... }:
{
    environment.systemPackages = with pkgs; [
        # Office
        anytype
        onlyoffice-desktopeditors
        evince
    ];

    environment.persistence."/persist" = {
        users.${username} = {
            directories = [
                ".config/anytype"
            ];
        };
    };
}