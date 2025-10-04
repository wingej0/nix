{ lib, inputs, ... }:
{
    imports = [
        inputs.impermanence.nixosModules.impermanence
    ];

    environment.persistence."/persist" = {
        enable = true;  # NB: Defaults to true, not needed
        hideMounts = true;
        directories = [
            "/var/log"
            "/var/lib/bluetooth"
            "/var/lib/nixos"
            "/var/lib/systemd/coredump"
            "/etc/NetworkManager/system-connections"
            "/etc/cups"
            { directory = "/var/lib/colord"; user = "colord"; group = "colord"; mode = "u=rwx,g=rx,o="; }
            
            # Flatpak and virt-manager
            "/var/lib/flatpak"
            "/var/lib/libvirt"
            
            # Nordvpn
            "/var/lib/nordvpn"

        ];
        files = [
            "/etc/machine-id"
            { file = "/var/keys/secret_file"; parentDirectory = { mode = "u=rwx,g=,o="; }; }
        ];
        users.wingej0 = {
            directories = [
                "Desktop"
                "Downloads"
                "Templates"
                ".dotfiles"
                { directory = ".gnupg"; mode = "0700"; }
                { directory = ".ssh"; mode = "0700"; }
                { directory = ".nixops"; mode = "0700"; }
                { directory = ".local/share/keyrings"; mode = "0700"; }
                ".local/share/direnv"
                ".local/share/TelegramDesktop"
                ".local/share/flatpak"
                ".local/share/themes"
                ".local/share/icons"
                ".local/share/applications"
                ".config/gh"
                ".config/anytype"
                ".config/Mailspring"
                ".config/Code"
                ".config/google-chrome"
                ".config/Mattermost"
                ".config/discord"
                ".config/nordvpn"
                ".config/sh.cider.genten"
                ".config/MongoDB Compass"
                ".config/vivaldi"
                ".config/remmina"
                ".zsh"
                ".vscode"
                ".scidvspc"
                ".config/obs-studio"
                ".config/Caprine"
		        ".config/dconf"
                ".var/app/app.zen_browser.zen"

                # Cosmic Desktop
                ".local/state/cosmic-comp"
                ".local/state/cosmic"
                ".config/cosmic"

                # Qtile
                # ".local/share/qtile"
                # ".config/picom"
                ".config/wallust"
                # ".cache/qtile"
                # ".config/rofi"
                ".config/variety"

                # XFCE
                # ".config/xfce4"
		        # ".cache/sessions"
                # ".config/autostart"
            ];
            files = [
                ".screenrc"
                ".gitconfig"
                ".zprofile"
                ".zlogin"
                ".histfile"
                ".zsh_history"
                ".config/cosmic-initial-setup-done"
            ];
        };
    };
}
