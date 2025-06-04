{ hostname, ... }:
{
    imports = 
        if hostname == "darter-pro" then 
        	[
				./darter-pro/configuration.nix
				./../modules/users.nix

				# Impermanence modules
				./../modules/impermanence.nix
				./../modules/persist.nix

				# System76 Drivers
				./../modules/system76.nix

		        # Packages
		        ./../modules/packages.nix
		        ./../modules/fonts.nix
		        ./../modules/shells.nix
		        ./../modules/virtualization.nix
				./../modules/cosmic-applets.nix
				./../modules/cosmic-themes.nix
				./../modules/nordvpn.nix
				./../modules/browsers.nix
				./../modules/communication.nix
				./../modules/games.nix
				./../modules/media.nix
				./../modules/development.nix
				./../modules/office.nix
        	]
        else if hostname == "sjsd-holysheet" then
			[
				./sjsd-holysheet/configuration.nix
				./../modules/users.nix

				# Impermanence modules
				./../modules/impermanence.nix
				./../modules/persist.nix

				# Packages
				./../modules/packages.nix
				./../modules/fonts.nix
		        ./../modules/shells.nix
				./../modules/development.nix
				./../modules/browsers.nix
			]
        else if hostname == "nix-vm" then
        	[
        		./nix-vm/configuration.nix
		        ./../modules/users.nix
		        ./../modules/persist.nix
		        ./../modules/packages.nix
		        ./../modules/fonts.nix
		        ./../modules/shells.nix
		        ./../modules/virtualization.nix
        	]
        else
            [ ];
}
