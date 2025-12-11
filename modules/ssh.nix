{ config, lib, pkgs, ... }:
{
    services.openssh = {
        enable = true;

        # Store host keys in /persist so they survive reboots
        hostKeys = [
            {
                path = "/persist/etc/ssh/ssh_host_ed25519_key";
                type = "ed25519";
            }
            {
                path = "/persist/etc/ssh/ssh_host_rsa_key";
                type = "rsa";
                bits = 4096;
            }
        ];

        settings = {
            # Disable password authentication for root
            PermitRootLogin = "prohibit-password";

            # Enable public key authentication
            PubkeyAuthentication = true;

            # Allow password authentication for regular users
            # Set to false if you want to enforce key-only authentication
            PasswordAuthentication = true;
        };
    };

    # Open SSH port in the firewall
    networking.firewall.allowedTCPPorts = [ 22 ];
}
