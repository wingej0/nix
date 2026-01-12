{ pkgs, username, config, ... }:
let
  homeDir = "/home/${username}";
in
{
    environment.systemPackages = with pkgs; [
        rclone
    ];

    # Enable FUSE for user mounts
    programs.fuse.userAllowOther = true;

    environment.persistence."/persist".users.${username}.directories = [
        ".config/rclone"
        ".cache/rclone"
    ];

    # Create mount points via tmpfiles
    systemd.tmpfiles.rules = [
        "d ${homeDir}/mounts 0755 ${username} users -"
        "d ${homeDir}/mounts/SJSD 0755 ${username} users -"
        "d ${homeDir}/mounts/3dgradebook 0755 ${username} users -"
    ];

    # System service for SJSD (runs as user)
    systemd.services.rclone-SJSD = {
        description = "Rclone mount for SJSD";
        after = [ "network-online.target" ];
        wants = [ "network-online.target" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
            Type = "simple";
            User = username;
            Group = "users";
            ExecStart = "${pkgs.rclone}/bin/rclone mount SJSD: ${homeDir}/mounts/SJSD --vfs-cache-mode full --config ${homeDir}/.config/rclone/rclone.conf --allow-other";
            ExecStop = "/run/wrappers/bin/fusermount -u ${homeDir}/mounts/SJSD";
            Restart = "on-failure";
            RestartSec = "10s";
            # Required for FUSE mounts
            AmbientCapabilities = "CAP_SYS_ADMIN";
            CapabilityBoundingSet = "CAP_SYS_ADMIN";
        };
    };

    # System service for 3dgradebook (runs as user)
    systemd.services.rclone-3dgradebook = {
        description = "Rclone mount for 3dgradebook";
        after = [ "network-online.target" ];
        wants = [ "network-online.target" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
            Type = "simple";
            User = username;
            Group = "users";
            ExecStart = "${pkgs.rclone}/bin/rclone mount 3dgradebook: ${homeDir}/mounts/3dgradebook --vfs-cache-mode full --config ${homeDir}/.config/rclone/rclone.conf --allow-other";
            ExecStop = "/run/wrappers/bin/fusermount -u ${homeDir}/mounts/3dgradebook";
            Restart = "on-failure";
            RestartSec = "10s";
            # Required for FUSE mounts
            AmbientCapabilities = "CAP_SYS_ADMIN";
            CapabilityBoundingSet = "CAP_SYS_ADMIN";
        };
    };
}
