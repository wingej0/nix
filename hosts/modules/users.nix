{ config, inputs, username, hostname, ... }:
{
    imports = [ 
        inputs.home-manager.nixosModules.home-manager
        ./password.nix 
    ];

    users.users.${username} = {
        isNormalUser = true;
        description = "${username}";        
        extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.   
    };
    

    home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        extraSpecialArgs = { inherit inputs username hostname; };

        users.${username} = {
            imports = [ ../../home/home.nix ];
            programs.home-manager.enable = true;
            home = {
                stateVersion = "24.05";
                username = "${username}";
                homeDirectory = "/home/${username}";
            };
        };
    };
}