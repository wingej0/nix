{ config, pkgs, inputs, username, ... }:
{
    imports = [
        inputs.nix-flatpak.nixosModules.nix-flatpak
    ];
    
    # Enable flatpak service (required for nix-flatpak)
    services.flatpak.enable = true;

    # Enable remote repos
    services.flatpak.remotes = [
        {
            name = "flathub";
            location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
        }
    ];

    # Install flatpaks declaratively
    services.flatpak = {
        packages = [
            "us.zoom.Zoom"
            "org.gnome.NetworkDisplays"
        ];
    };

    # Firewall rules for gnome-network-displays (WiFi Display/Miracast)
    networking.firewall.allowedTCPPorts = [ 7236 7250 ];
    networking.firewall.allowedUDPPorts = [ 7236 ];

    # Persist any folders for flatpaks
    environment.persistence."/persist" = {
        users.${username} = {
            directories = [
                ".local/share/flatpak"
                ".var/app/us.zoom.Zoom"
            ];
        };
    };
}