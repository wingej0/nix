# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Kernel
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Hibernation configuration
  boot.resumeDevice = "/dev/disk/by-uuid/d37128be-6d28-497f-a491-f2d40f9b2372";
  boot.kernelParams = [ "resume=/dev/disk/by-uuid/d37128be-6d28-497f-a491-f2d40f9b2372" ];

  # Networking
  networking.hostName = "darter-pro";
  networking.networkmanager.enable = true;

  hardware.bluetooth.enable = true; # enables support for Bluetooth
  hardware.bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot

  # Set your time zone.
  time.timeZone = "America/Denver";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  # Speed up the shutdown
  # systemd.settings.Manager = "DefaultTimeoutStopSec=5s";
  # systemd.user.extraConfig = "DefaultTimeoutStopSec=5s";

  # Enable appimage support
  programs.appimage.enable = true;
  programs.appimage.binfmt = true;
  
  # Configure keymap in X11
  services.xserver.xkb.layout = "us";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Declarative printer configuration (Canon at 10.40.0.70)
  hardware.printers = {
    ensurePrinters = [
      {
        name = "Canon-GPR53";
        location = "10.40.0.70";
        description = "Canon GPR-53 PostScript Printer";
        deviceUri = "lpd://10.40.0.70";
        model = "drv:///sample.drv/generpcl.ppd";
        ppdOptions = {
          PageSize = "Letter";
        };
      }
    ];
    ensureDefaultPrinter = "Canon-GPR53";
  };

  # Sound
  services.pipewire = {
    enable = true;
    pulse.enable = true;
  };

  # Enable flakes
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.05"; # Did you read the comment?
}

