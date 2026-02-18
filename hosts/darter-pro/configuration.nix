# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Networking
  networking.hostName = "darter-pro";

  # Kernel
  boot.resumeDevice = "/dev/disk/by-uuid/d37128be-6d28-497f-a491-f2d40f9b2372";
  boot.kernelParams = [ "resume=/dev/disk/by-uuid/d37128be-6d28-497f-a491-f2d40f9b2372" ];

  # Declarative printer configuration (Canon at 10.40.0.70)
  hardware.printers = {
    ensurePrinters = [
      {
        name = "Canon-GPR53";
        location = "10.40.0.70";
        description = "Canon GPR-53 PostScript Printer";
        deviceUri = "lpd://10.40.0.70";
        model = "drv:///sample.drv/generic.ppd";
        ppdOptions = {
          PageSize = "Letter";
        };
      }
    ];
    ensureDefaultPrinter = "Canon-GPR53";
  };
}

