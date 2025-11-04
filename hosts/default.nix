{ hostname, ... }:
{
    imports = 
        if hostname == "darter-pro" then 
        	[
				./darter-pro/configuration.nix
				./../modules/users.nix

				# Desktops
				# ./../desktops/cosmic.nix
				./../desktops/xfce.nix
				# ./../desktops/cinnamon.nix
				# ./../desktops/gnome.nix
				# ./../desktops/plasma.nix

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
				./../modules/nordvpn.nix
				./../modules/browsers.nix
				./../modules/communication.nix
				./../modules/games.nix
				./../modules/media.nix
				./../modules/development.nix
				./../modules/office.nix
				./../modules/flatpak.nix
				./../modules/ai.nix

				# Services
				./../modules/cosmic-bg.nix
        	]
		else if hostname == "nix-vm" then
			[
				./nix-vm/configuration.nix
				./../modules/users.nix

				# Desktops
				./../desktops/gnome.nix

				# Impermanence modules
				./../modules/impermanence.nix
				./../modules/persist.nix

				# Packages
				./../modules/packages.nix
				./../modules/fonts.nix
				./../modules/shells.nix
				./../modules/virtualization.nix
				./../modules/browsers.nix
				./../modules/communication.nix
				./../modules/games.nix
				./../modules/media.nix
				./../modules/development.nix
			]
        else
            [ ];
}
