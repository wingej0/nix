{ lib, inputs, username, ... }:
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
        users.${username} = {
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
                ".local/share/themes"
                ".local/share/icons"
                ".local/share/applications"
                ".config/gh"
                ".config/nordvpn"
                ".config/sh.cider.genten"
                ".config/remmina"
                ".zsh"
		        ".config/dconf"
                ".config/wallust"
                ".config/variety"
            ];
            files = [
                ".screenrc"
                ".gitconfig"
                ".zprofile"
                ".zlogin"
                ".histfile"
                ".zsh_history"
                ".cache/wallust/sequences"
            ];
        };
    };

    security.sudo.extraConfig = ''
        # rollback results in sudo lectures after each reboot
        Defaults lecture = never
    '';
}
