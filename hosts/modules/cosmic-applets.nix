{ config, pkgs, ... }:
{
    environment.systemPackages = with pkgs; 
        let
            cosmic-ext-applet-clipboard-manager = pkgs.callPackage  ./clipboard-manager.nix {}; 
            cosmic-ext-applet-caffeine = pkgs.callPackage ./cosmic-caffeine.nix {};
            cosmic-ext-applet-emoji-selector = pkgs.callPackage ./emoji-selector.nix {};
        in [
            cosmic-ext-applet-clipboard-manager 
            cosmic-ext-applet-caffeine
            cosmic-ext-applet-emoji-selector
        ];
}