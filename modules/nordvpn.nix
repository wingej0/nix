{ config, pkgs, inputs, ... }:
{
  imports = [
    inputs.nur.modules.nixos.default
    inputs.nur.legacyPackages.x86_64-linux.repos.wingej0.modules.nordvpn
  ];

  # Install NordVPN
  nixpkgs.overlays = [
    (final: prev: {
      nordvpn = pkgs.nur.repos.wingej0.nordvpn;
    })
  ];

  # Enable the service
  services.nordvpn.enable = true;

  # Enable WireGuard for NordVPN
  networking.wireguard.enable = true;

  # Configure firewall for NordVPN
  networking.firewall.checkReversePath = false; # Required for NordVPN to work properly
  networking.firewall.allowedTCPPorts = [ 443 ]; # NordVPN alternative connection method
  networking.firewall.allowedUDPPorts = [ 1194 ]; # OpenVPN port
}
