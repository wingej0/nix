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
            { directory = "/var/lib/colord"; user = "colord"; group = "colord"; mode = "u=rwx,g=rx,o="; }
        ];
        files = [
            "/etc/machine-id"
            { file = "/var/keys/secret_file"; parentDirectory = { mode = "u=rwx,g=,o="; }; }
        ];
        users.wingej0 = {
            directories = [
                "Downloads"
                "Music"
                "Pictures"
                "Documents"
                "Videos"
                ".dotfiles"
                { directory = ".gnupg"; mode = "0700"; }
                { directory = ".ssh"; mode = "0700"; }
                { directory = ".nixops"; mode = "0700"; }
                { directory = ".local/share/keyrings"; mode = "0700"; }
                ".local/share/direnv"
                ".local/state/cosmic"
                ".local/state/cosmic-comp"
                ".config/gh"
                ".config/cosmic"
                ".config/anytype"
                ".config/Mailspring"
                ".config/Code"
                ".config/google-chrome"
                ".mozilla"
            ];
            files = [
                ".screenrc"
                ".gitconfig"
                ".zshenv"
                ".zprofile"
                ".zlogin"
                ".histfile"
                ".pk10.zsh"
            ];
        };
    };
}