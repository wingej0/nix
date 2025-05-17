{ hostname, ... }:
{
    imports = 
        if hostname == "darter-pro" then 
        	[
			./darter-pro/configuration.nix
		        ./modules/users.nix
		        ./modules/persist.nix
		        ./modules/packages.nix
		        ./modules/fonts.nix
		        ./modules/shells.nix
		        ./modules/system76.nix
		        ./modules/virtualization.nix
        	]
        else if hostname == "nix-vm" then
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
