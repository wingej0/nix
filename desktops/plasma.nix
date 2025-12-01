{ config, lib, pkgs, inputs, username, ... }:
{
    services.displayManager.sddm.enable = true;
    services.displayManager.sddm.wayland.enable = true;
    services.desktopManager.plasma6.enable = true;

    home-manager.users.${username} = {
        imports = [ inputs.plasma-manager.homeManagerModules.plasma-manager ];

        programs.plasma = {
            enable = true;

            workspace.theme = "breeze-dark";
            workspace.colorScheme = "BreezeDark";

            panels = [
                {
                    location = "top";
                    floating = true;
                }
            ];
        };
    };
}