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

            shortcuts = {
                # KRunner
                "org.kde.krunner.desktop"."_launch" = "Meta";

                # Window Management
                "kwin"."Window Close" = "Meta+Q";

                # Lock Screen
                "ksmserver"."Lock Session" = "Meta+Escape";

                # Workspace Switching (1-12)
                "kwin"."Switch to Desktop 1" = "Meta+1";
                "kwin"."Switch to Desktop 2" = "Meta+2";
                "kwin"."Switch to Desktop 3" = "Meta+3";
                "kwin"."Switch to Desktop 4" = "Meta+4";
                "kwin"."Switch to Desktop 5" = "Meta+5";
                "kwin"."Switch to Desktop 6" = "Meta+6";
                "kwin"."Switch to Desktop 7" = "Meta+7";
                "kwin"."Switch to Desktop 8" = "Meta+8";
                "kwin"."Switch to Desktop 9" = "Meta+9";
                "kwin"."Switch to Desktop 10" = "Meta+0";
                "kwin"."Switch to Desktop 11" = "Meta+-";
                "kwin"."Switch to Desktop 12" = "Meta+=";

                # Move Window to Workspace (1-12)
                "kwin"."Window to Desktop 1" = "Meta+Shift+1";
                "kwin"."Window to Desktop 2" = "Meta+Shift+2";
                "kwin"."Window to Desktop 3" = "Meta+Shift+3";
                "kwin"."Window to Desktop 4" = "Meta+Shift+4";
                "kwin"."Window to Desktop 5" = "Meta+Shift+5";
                "kwin"."Window to Desktop 6" = "Meta+Shift+6";
                "kwin"."Window to Desktop 7" = "Meta+Shift+7";
                "kwin"."Window to Desktop 8" = "Meta+Shift+8";
                "kwin"."Window to Desktop 9" = "Meta+Shift+9";
                "kwin"."Window to Desktop 10" = "Meta+Shift+0";
                "kwin"."Window to Desktop 11" = "Meta+Shift+-";
                "kwin"."Window to Desktop 12" = "Meta+Shift+=";
            };

            # Custom keyboard shortcuts for launching applications
            configFile = {
                "kglobalshortcutsrc"."kitty.desktop"."_launch" = "Meta+Return";
                "kglobalshortcutsrc"."org.kde.dolphin.desktop"."_launch" = "Meta+Shift+Return";
            };
        };
    };
}