{ config, pkgs, inputs, ... }:
{
    imports = [
        {
            nix.settings = {
                substituters = [ "https://cosmic.cachix.org/" ];
                trusted-public-keys = [ "cosmic.cachix.org-1:Dya9IyXD4xdBehWjrkPv6rtxpmMdRel02smYzA85dPE=" ];
            };
        }
        inputs.nixos-cosmic.nixosModules.default
    ];

    environment.systemPackages = with pkgs; [
        cosmic-ext-applet-clipboard-manager
        cosmic-ext-applet-caffeine
        cosmic-ext-applet-emoji-selector
    ];
}