{ hostname, ... }:
{
    imports = 
        if hostname == "darter-pro" then 
        	[
				./darter-pro/configuration.nix
				./../modules/users.nix

				# Desktops
				./../desktops/cosmic.nix
				# ./../desktops/xfce.nix

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
				# ./../modules/nordvpn.nix
				./../modules/browsers.nix
				./../modules/communication.nix
				./../modules/games.nix
				./../modules/media.nix
				./../modules/development.nix
				./../modules/office.nix
				./../modules/ollama.nix
        	]
        else if hostname == "the-holysheet" then
			[
				./the-holysheet/configuration.nix
				./../modules/users.nix

				# Packages
				./../modules/packages.nix
				./../modules/fonts.nix
		        ./../modules/shells.nix
				./../modules/development.nix
				./../modules/browsers.nix
				./../modules/mongodb.nix
				./../modules/remote-access.nix
			]
		else if hostname == "dis-winget" then
			[
				./dis-winget/configuration.nix
				./../modules/users.nix

				# Packages
				./../modules/packages.nix
				./../modules/fonts.nix
		        ./../modules/shells.nix
				./../modules/development.nix
				./../modules/browsers.nix
				./../modules/remote-access.nix
				./../modules/ollama.nix
				./../modules/n8n.nix
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
