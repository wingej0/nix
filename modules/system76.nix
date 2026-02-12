{ config, pkgs, ... }:
{
  hardware.system76.enableAll = true;
  services.power-profiles-daemon.enable = false;
  services.thermald.enable = true;

  # Enable hardware video acceleration (VA-API) for Intel iGPU
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver
      libvdpau-va-gl
    ];
  };

  environment.systemPackages = with pkgs; [
    system76-firmware
    libva-utils  # Provides vainfo to verify VA-API is working
  ];
}