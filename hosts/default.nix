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
        	]
        else
            [ ];
}
