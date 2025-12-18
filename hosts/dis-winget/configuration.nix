# Configuration for dis-winget
{ config, lib, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Networking
  networking.hostName = "dis-winget";
  networking.networkmanager.enable = true;

  # Bluetooth
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  # Time zone
  time.timeZone = "America/Denver";

  # Locale
  i18n.defaultLocale = "en_US.UTF-8";

  # Keymap
  services.xserver.xkb.layout = "us";

  # Printing
  services.printing.enable = true;

  # Sound (PipeWire)
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  # Enable appimage support
  programs.appimage.enable = true;
  programs.appimage.binfmt = true;

  # Enable flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  # State version
  system.stateVersion = "25.11";
}
