{ config, pkgs, username, ... }:
{
    nixpkgs.overlays = [
        (final: prev: {
            mongodb-compass = prev.mongodb-compass.overrideAttrs (oldAttrs: {
                postFixup = (oldAttrs.postFixup or "") + ''
                    wrapProgram $out/bin/mongodb-compass \
                        --add-flags "--password-store=gnome-libsecret --ignore-additional-command-line-flags"
                '';
            });
        })
    ];

    environment.systemPackages = with pkgs; [
        # Development
        vscode-fhs
        mongodb-compass
        insomnia
        unixODBC
        unixODBCDrivers.msodbcsql18
        nodejs
        jq
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