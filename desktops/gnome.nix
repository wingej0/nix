{ config, lib, pkgs, inputs, username, ... }:
{
    services.displayManager.gdm.enable = true;
    services.desktopManager.gnome.enable = true;

    # Enable flatpaks
    services.flatpak.enable = true;
    services.blueman.enable = true;

    environment.systemPackages = with pkgs; [
        # Gnome extensions
        pkgs.gnome-tweaks
        gnomeExtensions.dash-to-dock
        gnomeExtensions.blur-my-shell
        gnomeExtensions.appindicator
        gnomeExtensions.caffeine
        gnomeExtensions.clipboard-indicator
        gnomeExtensions.alphabetical-app-grid
        gnomeExtensions.tiling-assistant
        gnomeExtensions.user-themes
        gnomeExtensions.gnordvpn-local

        gnome-calculator
        gnome-remote-desktop
    ];

    # Persistence
    environment.persistence."/persist" = {
        users.wingej0 = {
            files = [
                ".config/gnome-initial-setup-done"
            ];
        };
    };

    home-manager.users.${username} = {

        dconf = {
            enable = true;
            settings = {

                "org/virt-manager/virt-manager/connections" = {
                    autoconnect = ["qemu:///system"];
                    uris = ["qemu:///system"];
                };

                "org/gnome/shell" = {
                    disable-user-extensions = false;
                
                    favorite-apps = [
                        "app.zen_browser.zen.desktop"
                        "google-chrome.desktop"
                        "Mailspring.desktop"
                        "chrome-fmgjjmmmlfnkbppncabfkddbjimcfncm-Default.desktop"
                        "chrome-mdpkiolbdkhdjpekfbkbmhigcaggjagi-Default.desktop"
                        "org.telegram.desktop.desktop"
                        "caprine.desktop"
                        "Mattermost.desktop"
                        "discord.desktop"
                        "chrome-kjbdgfilnfhdoflbpgamdcdgpehopbep-Default.desktop"
                        "anytype.desktop"
                        "org.remmina.Remmina.desktop"
                        "kitty.desktop"
                        "code.desktop"
                        "mongodb-compass.desktop"
                        "onlyoffice-desktopeditors.desktop"
                        "com.github.phase1geo.annotator.desktop"
                        "com.obsproject.Studio.desktop"
                        "org.kde.kdenlive.desktop"
                        "cider.desktop"
                        "org.gnome.Nautilus.desktop"
                    ];


                    # `gnome-extensions list` for a list
                    enabled-extensions = [
                        "AlphabeticalAppGrid@stuarthayhurst"
                        "appindicatorsupport@rgcjonas.gmail.com"
                        "blur-my-shell@aunetx"
                        "caffeine@patapon.info"
                        "clipboard-indicator@tudmotu.com"
                        "dash-to-dock@micxgx.gmail.com"
                        "tiling-assistant@leleat-on-github"
                        "user-theme@gnome-shell-extensions.gcampax.github.com"
                    ];
                };

                "org/gnome/mutter" = {
                    dynamic-workspaces = true;
                    workspaces-only-on-primary = true;
                };

                # "org/gnome/desktop/wm/preferences" = {
                #     num-workspaces = 12;
                # };

                "org/gnome/shell/extensions/user-theme" = {
                    name = "Orchis";
                };

                "org/gnome/desktop/interface" = {
                    show-battery-percentage = true;
                    enable-hot-corners = false;
                    clock-format = "12h";
                    clock-show-weekday = true;
                    clock-show-date = true;
                };

                "org/gnome/desktop/peripherals/touchpad" = {
                    tap-to-click = true;
                };

                "org/gnome/mutter/wayland/keybindings" = {
                    restore-shortcuts = [];
                };

                "org/gnome/shell/keybindings" = {
                    # Remove favorite application keybinds that conflict with custom workspace binds
                    switch-to-application-1 = [];
                    switch-to-application-2 = [];
                    switch-to-application-3 = [];
                    switch-to-application-4 = [];
                    switch-to-application-5 = [];
                    switch-to-application-6 = [];
                    switch-to-application-7 = [];
                    switch-to-application-8 = [];
                    switch-to-application-9 = [];
                    switch-to-application-10 = [];
                    switch-to-application-11 = [];
                    switch-to-application-12 = [];
                };

                "org/gnome/desktop/wm/keybindings" = {
                    close = ["<Super>q"];
                    move-to-workspace-1 = ["<Shift><Super>1"];
                    move-to-workspace-2 = ["<Shift><Super>2"];
                    move-to-workspace-3 = ["<Shift><Super>3"];
                    move-to-workspace-4 = ["<Shift><Super>4"];
                    move-to-workspace-5 = ["<Shift><Super>5"];
                    move-to-workspace-6 = ["<Shift><Super>6"];
                    move-to-workspace-7 = ["<Shift><Super>7"];
                    move-to-workspace-8 = ["<Shift><Super>8"];
                    move-to-workspace-9 = ["<Shift><Super>9"];
                    move-to-workspace-10 = ["<Shift><Super>0"];
                    move-to-workspace-11 = ["<Shift><Super>minus"];
                    move-to-workspace-12 = ["<Shift><Super>equal"];
                    switch-to-workspace-1 = ["<Super>1"];
                    switch-to-workspace-2 = ["<Super>2"];
                    switch-to-workspace-3 = ["<Super>3"];
                    switch-to-workspace-4 = ["<Super>4"];
                    switch-to-workspace-5 = ["<Super>5"];
                    switch-to-workspace-6 = ["<Super>6"];
                    switch-to-workspace-7 = ["<Super>7"];
                    switch-to-workspace-8 = ["<Super>8"];
                    switch-to-workspace-9 = ["<Super>9"];
                    switch-to-workspace-10 = ["<Super>0"];
                    switch-to-workspace-11 = ["<Super>minus"];
                    switch-to-workspace-12 = ["<Super>equal"];
                };

                "org/gnome/settings-daemon/plugins/media-keys" = {

                    screensaver = ["<Super>Escape"];
        
                    custom-keybindings = [
                        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
                        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
                        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/"
                        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/"
                        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom4/"
                        "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom5/"
                    ];
                };

                "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
                    name = "Terminal";
                    command = "kitty";
                    binding = "<Super>Return";
                };

                "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" = {
                    name = "Files";
                    command = "nautilus";
                    binding = "<Shift><Super>Return";
                };

                "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2" = {
                    name = "Next Wallpaper";
                    command = "variety -n";
                    binding = "<Super>w";
                };

                "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3" = {
                    name = "Previous Wallpaper";
                    command = "variety -p";
                    binding = "<Shift><Super>w";
                };

                "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom4" = {
                    name = "Favorite Wallpaper";
                    command = "variety -f";
                    binding = "<Alt>f";
                };

                "org/gnome/shell/extensions/dash-to-dock" = {
                    multi-monitor = true;
                    dock-position = "LEFT";
                    dash-max-icon-size = 20;
                    hot-keys = false;
                    running-indicator-style = "DASHES";
                    show-mounts = false;
                    show-trash = false;
                };

                "org/gnome/shell/extensions/blur-my-shell/panel" = {
                    pipeline = "pipeline_default_rounded";
                };

                "org/gnome/shell/extensions/tiling-assistant" = {
                    window-gap = 8;
                    single-screen-gap = 8;
                    maximize-with-gap = true;
                    dynamic-keybinding-behavior = 2;
                    tile-edit-mode = ["<Super>g"];
                };
            };
        };

        gtk = {
            enable = true;
        
            gtk3 = {
                extraConfig = {
                    gtk-application-prefer-dark-theme = 0;
                };
            };

            gtk4 = {
                extraConfig = {
                    gtk-application-prefer-dark-theme = 0;
                };
            };

            font = {
                name = "Fira Code Nerd Font";
                size = 11;
            };
        };
    };
}