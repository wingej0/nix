{ hostname, ... }:
let
  # Modules shared across all hosts
  commonModules = [
    ./../modules/users.nix
    ./../modules/impermanence.nix
    ./../modules/persist.nix
    ./../modules/packages.nix
    ./../modules/fonts.nix
    ./../modules/shells.nix
    ./../modules/virtualization.nix
    ./../modules/browsers.nix
    ./../modules/communication.nix
    ./../modules/games.nix
    ./../modules/media.nix
    ./../modules/development.nix
  ];

  # Desktop options (uncomment one per host)
  desktops = {
    gnome = ./../desktops/gnome.nix;
    plasma = ./../desktops/plasma.nix;
    cosmic = ./../desktops/cosmic.nix;
    xfce = ./../desktops/xfce.nix;
    cinnamon = ./../desktops/cinnamon.nix;
  };

  # Host-specific configurations
  hostConfigs = {
    darter-pro = [
      ./darter-pro/configuration.nix

      # Desktop environment
      # desktops.gnome
      # desktops.plasma
      # desktops.cosmic
      desktops.xfce
      # desktops.cinnamon

      # System76 drivers
      ./../modules/system76.nix

      # Additional packages
      # ./../modules/nordvpn.nix
      ./../modules/office.nix
      ./../modules/flatpak.nix
      ./../modules/ai.nix

      # Services
      ./../modules/cosmic-bg.nix
    ];

    nix-vm = [
      ./nix-vm/configuration.nix

      # Desktop environment
      desktops.gnome
      # desktops.plasma
      # desktops.cosmic
      # desktops.xfce
      # desktops.cinnamon
    ];
  };
in
{
  imports = commonModules ++
    (if builtins.hasAttr hostname hostConfigs
     then hostConfigs.${hostname}
     else throw "Unknown hostname: ${hostname}. Supported hosts: ${builtins.concatStringsSep ", " (builtins.attrNames hostConfigs)}");
}
