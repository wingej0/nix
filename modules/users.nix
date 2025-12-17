{ config, inputs, username, hostname, ... }:
let
  # User configuration mapping
  userConfigs = {
    wingej0 = {
      description = "Jeff Winget";
      hashedPasswordFile = "/persist/password_hash";
      extraGroups = [ "wheel" "nordvpn" "libvirtd" ];
    };
  };

  # Get the current user's config
  userConfig = userConfigs.${username};
in
{
    imports = [
        inputs.home-manager.nixosModules.home-manager
    ];

    users.users.${username} = {
        isNormalUser = true;
        description = userConfig.description;
        hashedPasswordFile = userConfig.hashedPasswordFile;
        extraGroups = userConfig.extraGroups;
    };
    

    home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        extraSpecialArgs = { inherit inputs username hostname; };

        users.${username} = {
            imports = [ ./../home/home.nix ];
            programs.home-manager.enable = true;
            home = {
                stateVersion = "25.05";
                username = "${username}";
                homeDirectory = "/home/${username}";
            };
        };
    };
}