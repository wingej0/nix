{ config, pkgs, ... }:
{
    environment.systemPackages = with pkgs; [
        sunshine
        moonlight-qt
    ];

    security.wrappers.sunshine = {
        owner = "root";
        group = "root";
        capabilities = "cap_sys_admin+p";
        source = "${pkgs.sunshine}/bin/sunshine";
    };

    services.avahi.publish = {
        enable = true;
        userServices = true;
    };

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
    networking.firewall.allowedTCPPorts = [ 22 3389 27017 47984 47989 47990 48010 ];
    networking.firewall.allowedUDPPorts = [ 22 3389 27017 ];
    networking.firewall.allowedUDPPortRanges = [
        {from = 47998; to = 4800;}
    ];
}