{ config, pkgs, username, ... }:
{
    environment.systemPackages = with pkgs; [
        virt-manager
        distrobox
    ];

    # Virtualization
    virtualisation.libvirtd.enable = true;
    programs.virt-manager.enable = true;

    virtualisation.podman = {
        enable = true;
        dockerCompat = true;
    };

    # Persist distrobox containers
    environment.persistence."/persist" = {
        users.${username} = {
            directories = [
                ".local/share/containers"
            ];
        };
    };
}