{ config, lib, pkgs, inputs, ... }:
let
    cosmic-bg-theme = inputs.cosmic-applets-collection.packages.${pkgs.system}.cosmic-ext-bg-theme;
in
{
    systemd.user.services.cosmic-ext-bg-theme = {
        description = "COSMIC Background Theme Extension";
        documentation = [ "man:cosmic-ext-bg-theme(1)" ];
        partOf = [ "graphical-session.target" ];
        wantedBy = [ "graphical-session.target" ];
        
        serviceConfig = {
            Type = "simple";
            ExecStart = "${cosmic-bg-theme}/bin/cosmic-ext-bg-theme";
            Restart = "on-failure";
        };
    };
}