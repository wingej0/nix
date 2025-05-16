{ hostname, ... }:
{
    imports = 
        if hostname == "nix-vm" then
        	[
        		./nix-vm/configuration.nix
                ./modules/users.nix
                ./modules/persist.nix
                ./modules/packages.nix
                ./modules/fonts.nix
                ./modules/shells.nix
                ./modules/system76.nix
                ./modules/virtualization.nix
        	]
        else
            [ ];
}
