{ hostname, ... }:
{
    imports = 
        if hostname == "darter-pro" then 
        	[
				./darter-pro/configuration.nix
				./../modules/users.nix

				# Desktops
				./../desktops/cosmic.nix

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
        	]
        else
            [ ];
}
