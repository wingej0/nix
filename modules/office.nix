{ config, pkgs, pkgs-stable, username, ... }:
{
    environment.systemPackages = with pkgs; [
        # Office
        pkgs-stable.anytype  # Using stable branch to avoid GCC 15 build failure in protoc-gen-js
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