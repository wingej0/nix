{ hostname, ... }:
{
    imports = 
        if hostname == "nix-vm" then
        	[
        		./nix-vm/configuration.nix
                ./modules/mailspring.nix
                ./modules/users.nix
        	]
        else
            [ ];
}
