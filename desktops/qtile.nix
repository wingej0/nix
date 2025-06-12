{ config, lib, pkgs, inputs, ... }:
{
    imports = [
        # (_: { nixpkgs.overlays = [ inputs.qtile-flake.overlays.default ]; })
        # ./../overlays/qtile-overlay.nix
    ];

    specialisation = {
        qtile.configuration = {
            # Enable the X11 windowing system.
            services.xserver.enable = true;

            services.xserver.windowManager.qtile = {
                enable = true;
                extraPackages = python3Packages: with python3Packages; [
                    qtile-extras
                ];
            };
        };
    };
}