{ config, pkgs, inputs, ... }:
{
    environment.systemPackages = with pkgs; 
        let
            cosmic-ext-applet-clipboard-manager = pkgs.callPackage ./../packages/clipboard-manager.nix {inherit inputs;};
            cosmic-ext-applet-caffeine = pkgs.callPackage ./../packages/cosmic-caffeine.nix {inherit inputs;};
            # cosmic-ext-applet-emoji-selector = pkgs.callPackage ./../packages/emoji-selector.nix {inherit inputs;};
        in [
            cosmic-ext-applet-clipboard-manager 
            cosmic-ext-applet-caffeine
            # cosmic-ext-applet-emoji-selector
        ];
}
