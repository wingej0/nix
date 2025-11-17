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
            "app.zen_browser.zen"
            "us.zoom.Zoom"
            "org.gnome.NetworkDisplays"
        ];
    };

    # Persist any folders for flatpaks
    environment.persistence."/persist" = {
        users.${username} = {
            directories = [
                ".local/share/flatpak"
                ".var/app/app.zen_browser.zen"
                ".var/app/us.zoom.Zoom"
            ];
        };
    };
}