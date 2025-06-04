{ config, pkgs, lib, ... }:
{
    # Allow installation of unfree corefonts package
    nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [ "corefonts" "vistafonts" ];

    fonts.packages = with pkgs; [
        noto-fonts
        noto-fonts-cjk-sans
        noto-fonts-color-emoji
        dejavu_fonts
        nerd-fonts.fira-code
        font-awesome
        corefonts
        vistafonts
    ];
}