{ config, pkgs, lib, ... }:
{
  # Enable mDNS for .local hostname resolution
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    publish = {
      enable = true;
      addresses = true;
      domain = true;
      workstation = true;
    };
    # Exclude virtual interfaces (libvirt, docker, etc.)
    extraConfig = ''
      [server]
      deny-interfaces=virbr0,docker0
    '';
  };

  # Open mDNS port in firewall
  networking.firewall.allowedUDPPorts = [ 5353 ];
}
