{ config, inputs, username, hostname, stateVersion, useStableBranch ? false, ... }:
let
  # User configuration mapping
  userConfigs = {
    wingej0 = {
      description = "Jeff Winget";
      hashedPasswordFile = "/persist/password_hash";
      extraGroups = [ "wheel" "nordvpn" "libvirtd" ];
    };

    jwinget = {
      description = "Jeff Winget";
      hashedPasswordFile = "/persist/jwinget_password_hash";
      extraGroups = [ "wheel" ];
    };
  };

  # Get the current user's config
  userConfig = userConfigs.${username};

  # Select the appropriate home-manager based on branch
  homeManagerModule = if useStableBranch
    then inputs.home-manager-stable.nixosModules.home-manager
    else inputs.home-manager.nixosModules.home-manager;
in
{
    imports = [
        homeManagerModule
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
        extraSpecialArgs = { inherit inputs username hostname stateVersion; };

        users.${username} = {
            imports = [ ./../home/home.nix ];
            programs.home-manager.enable = true;
            home = {
                stateVersion = stateVersion;
                username = "${username}";
                homeDirectory = "/home/${username}";
            };
        };
    };
}
