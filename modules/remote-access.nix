{ config, pkgs, ... }:
{
    environment.systemPackages = with pkgs; [
        gnome-remote-desktop
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

    services.xrdp.enable = true;
    services.xrdp.defaultWindowManager = "${pkgs.gnome-session}/bin/gnome-session";
    services.xrdp.openFirewall = true;

    # Disable the GNOME3/GDM auto-suspend feature that cannot be disabled in GUI!
    # If no user is logged in, the machine will power down after 20 minutes.
    systemd.targets.sleep.enable = false;
    systemd.targets.suspend.enable = false;
    systemd.targets.hibernate.enable = false;
    systemd.targets.hybrid-sleep.enable = false;

    # Open ports in the firewall.
    networking.firewall.allowedTCPPorts = [ 22 3389 27017 ];
    networking.firewall.allowedUDPPorts = [ 22 3389 27017 ];
}