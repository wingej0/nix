{ config, pkgs, ... }:
{
    environment.systemPackages = with pkgs; [
        gnome-remote-desktop
        gnome-session
        dconf-editor
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

    services.gnome.gnome-remote-desktop.enable = true;

    # Open ports in the firewall.
    networking.firewall.allowedTCPPorts = [ 22 3389 27017 ];
    networking.firewall.allowedUDPPorts = [ 22 3389 27017 ];
}