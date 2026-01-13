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
    ./../modules/ssh.nix
    ./../modules/mdns.nix
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
    qtile = ./../desktops/qtile.nix;
  };

  # Host-specific configurations
  hostConfigs = {
    darter-pro = [
      ./darter-pro/configuration.nix

      # Desktop environment
      # desktops.gnome
      # desktops.plasma
      # desktops.cosmic
      # desktops.xfce
      # desktops.cinnamon
      desktops.qtile

      # System76 drivers
      ./../modules/system76.nix

      # Additional packages
      ./../modules/rclone.nix
      ./../modules/nordvpn.nix
      ./../modules/office.nix
      ./../modules/flatpak.nix
      ./../modules/ai.nix
      ./../modules/mongodb.nix
      ./../modules/n8n.nix
      ./../modules/immich.nix
    ];

    nix-vm = [
      ./nix-vm/configuration.nix

      # Desktop environment
      desktops.gnome
      # desktops.qtile
      # desktops.cosmic
      # desktops.xfce
      # desktops.cinnamon
    ];

    dis-winget = [
      ./dis-winget/configuration.nix

      # Desktop environment
      desktops.gnome
      # desktops.plasma
      # desktops.cosmic
      # desktops.xfce
      # desktops.cinnamon
      # desktops.qtile

      # Optional modules
      ./../modules/ai.nix
      ./../modules/mongodb.nix
      ./../modules/n8n.nix
      ./../modules/ollama.nix

      # Nvidia Driver
      ./../modules/nvidia.nix
    ];

    the-holysheet = [
      ./the-holysheet/configuration.nix

      # Desktop environment
      desktops.gnome
      # desktops.plasma
      # desktops.cosmic
      # desktops.xfce
      # desktops.cinnamon
      # desktops.qtile

      # Optional modules
      ./../modules/office.nix
      ./../modules/ai.nix
      ./../modules/mongodb.nix
    ];

  };
in
{
  imports = commonModules ++
    (if builtins.hasAttr hostname hostConfigs
     then hostConfigs.${hostname}
     else throw "Unknown hostname: ${hostname}. Supported hosts: ${builtins.concatStringsSep ", " (builtins.attrNames hostConfigs)}");
}
