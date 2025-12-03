{ config, lib, pkgs, inputs, username, ... }:
{
    services.displayManager.sddm.enable = true;
    services.displayManager.sddm.wayland.enable = true;
    services.desktopManager.plasma6.enable = true;

    # Persistence
    environment.persistence."/persist" = {
        users.${username} = {
            files = [
                # Monitor config
                ".config/kwinoutputconfig.json"
            ];
        };
    };

    home-manager.users.${username} = {
        imports = [ inputs.plasma-manager.homeModules.plasma-manager ];

        programs.plasma = {
            enable = true;
            overrideConfig = true;

            #
            # High-level settings:
            #
            workspace = {
                theme = "breeze-dark";
                colorScheme = "BreezeDark";
                wallpaper = "${config.home-manager.users.${username}.home.homeDirectory}/Pictures/current_wallpaper.jpg";
            };

            #
            # Custom hotkey commands:
            #
            hotkeys.commands = {
                "launch-terminal" = {
                    name = "Launch Terminal";
                    key = "Meta+Return";
                    command = "kitty";
                };
                "launch-files" = {
                    name = "Launch Files";
                    key = "Meta+Shift+Return";
                    command = "dolphin";
                };
                "next-wallpaper" = {
                    name = "Next Wallpaper";
                    key = "Meta+W";
                    command = "variety -n";
                };
                "previous-wallpaper" = {
                    name = "Previous Wallpaper";
                    key = "Meta+Shift+W";
                    command = "variety -p";
                };
            };

            #
            # Panel configuration:
            #
            panels = [
                {
                    location = "top";
                    floating = true;
                }
            ];

            #
            # Keyboard shortcuts:
            #
            shortcuts = {
                # KRunner
                "org.kde.krunner.desktop"."_launch" = "Meta";

                # Session management
                ksmserver = {
                    "Lock Session" = "Meta+Escape";
                };

                # Window management and workspace switching
                kwin = {
                    # Window Management
                    "Window Close" = "Meta+Q";

                    # Overview
                    "Overview" = "Meta+D";

                    # Workspace Switching (1-12)
                    "Switch to Desktop 1" = "Meta+1";
                    "Switch to Desktop 2" = "Meta+2";
                    "Switch to Desktop 3" = "Meta+3";
                    "Switch to Desktop 4" = "Meta+4";
                    "Switch to Desktop 5" = "Meta+5";
                    "Switch to Desktop 6" = "Meta+6";
                    "Switch to Desktop 7" = "Meta+7";
                    "Switch to Desktop 8" = "Meta+8";
                    "Switch to Desktop 9" = "Meta+9";
                    "Switch to Desktop 10" = "Meta+0";
                    "Switch to Desktop 11" = "Meta+-";
                    "Switch to Desktop 12" = "Meta+=";

                    # Move Window to Workspace (1-12)
                    "Window to Desktop 1" = "Meta+Shift+1";
                    "Window to Desktop 2" = "Meta+Shift+2";
                    "Window to Desktop 3" = "Meta+Shift+3";
                    "Window to Desktop 4" = "Meta+Shift+4";
                    "Window to Desktop 5" = "Meta+Shift+5";
                    "Window to Desktop 6" = "Meta+Shift+6";
                    "Window to Desktop 7" = "Meta+Shift+7";
                    "Window to Desktop 8" = "Meta+Shift+8";
                    "Window to Desktop 9" = "Meta+Shift+9";
                    "Window to Desktop 10" = "Meta+Shift+0";
                    "Window to Desktop 11" = "Meta+Shift+-";
                    "Window to Desktop 12" = "Meta+Shift+=";
                };
            };

            #
            # Low-level configuration:
            #
            configFile = {
                "kwinrc"."Desktops" = {
                    "Number" = {
                        value = 9;
                    };
                    "Rows" = {
                        value = 3;
                    };
                };
                kwinrc.Xwayland.Scale = 1;
                kwinrc.Plugins.blurEnabled = true;
                kwinrc.TabBox.LayoutName = "coverswitch";
                kwinrc.Windows.AutoRaise = true;
                kwinrc.Windows.FocusPolicy = "FocusFollowsMouse";
                kwinrc.Windows.NextFocusPrefersMouse = true;
                # Set natural scrolling for touchpad
                kcminputrc."Libinput/1267/12864/ELAN0412:00 04F3:3240 Touchpad".NaturalScroll = true;
                # Cursor Theme
                kcminputrc.Mouse.cursorTheme = "Bibata-Modern-Classic";
            };
        };
    };
}