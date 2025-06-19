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
            
            # MongoDB
            "/var/db/mongodb"

            # Nordvpn
            "/var/lib/nordvpn"

            # Ollama
            "/var/lib/private/ollama"
            "/var/lib/private/open-webui"

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
                ".local/share/applications"
                ".config/gh"
                ".config/anytype"
                ".config/Mailspring"
                ".config/Code"
                ".config/google-chrome"
                ".config/Mattermost"
                ".config/discord"
                ".config/Element"
                ".config/nordvpn"
                ".config/sh.cider.genten"
                ".config/MongoDB Compass"
                ".config/rustdesk"
                ".var/app/app.zen_browser.zen"
                ".zsh"
                ".vscode"
                ".scidvspc"
                ".mongodb"
                ".config/obs-studio"

                # Cosmic Desktop
                ".local/state/cosmic-comp"
                ".local/state/cosmic"
                ".config/cosmic"

                # Cinnamon Desktop
                # ".config/cinnamon"
                # ".config/cinnamon-session"
                # ".local/share/cinnamon"
                # ".config/dconf"

                # Qtile
                ".config/qtile"
                ".local/share/qtile"
                ".config/picom"
                ".config/wallust"
                ".cache/qtile"
                ".cache/rofi"
                ".cache/wlogout"
		        ".config/variety"

                # XFCE
                ".config/xfce4"
		        ".cache/sessions"
                ".config/autostart"

            ];
            files = [
                ".screenrc"
                ".gitconfig"
                ".zprofile"
                ".zlogin"
                ".histfile"
                ".zsh_history"
            ];
        };
    };
}
