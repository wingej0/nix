{ config, pkgs, lib, username, ... }:
{
    environment.systemPackages = with pkgs; [
        virt-manager
        distrobox
    ];

    # Virtualization
    virtualisation.libvirtd.enable = true;
    programs.virt-manager.enable = true;

    # libvirt 11.x introduced virt-secret-init-encryption.service which hardcodes
    # /usr/bin/sh (doesn't exist on NixOS). Also, systemd-creds encrypt rejects
    # symlinks for credential.secret (ELOOP), so use --with-key=tpm2 instead.
    systemd.services.virt-secret-init-encryption.serviceConfig.ExecStart = lib.mkForce [
      ""
      "/bin/sh -c 'umask 0077 && (dd if=/dev/random status=none bs=32 count=1 | systemd-creds encrypt --with-key=tpm2 --name=secrets-encryption-key - /var/lib/libvirt/secrets/secrets-encryption-key)'"
    ];

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