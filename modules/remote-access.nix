{ config, pkgs, ... }:
{
    environment.systemPackages = with pkgs; [
        rustdesk-server
    ];

    services.openssh = {
        enable = true;
        ports = [ 22 ];
        settings = {
            PasswordAuthentication = true;
            AllowUsers = null; # Allows all users by default. Can be [ "user1" "user2" ]
            UseDns = true;
            X11Forwarding = false;
            PermitRootLogin = "no"; # "yes", "without-password", "prohibit-password", "forced-commands-only", "no"
        };
    };

    # Open ports in the firewall.
    networking.firewall.allowedTCPPorts = [ 22 27017 ];
    networking.firewall.allowedUDPPorts = [ 22 27017 ];
}