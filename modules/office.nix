{ config, pkgs, ... }:
{
    environment.systemPackages = with pkgs; [
        # Office
        anytype
        onlyoffice-bin
        evince
    ];

    environment.persistence."/persist" = {
        users.wingej0 = {
            directories = [
                ".config/anytype"
            ];
        };
    };
}