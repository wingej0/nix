{ config, inputs, username, hostname, ... }:
{
    imports = [ 
        inputs.home-manager.nixosModules.home-manager
        ./password.nix 
    ];

    
    users.users.wingej0 = {
        isNormalUser = true;
        initialHashedPassword = "$6$DC6usdc/o.Svf2X3$yyl4T3lbOjCUVma/io5nEWjaUxbl5ly//R39sr6tBHpLQQORaOVluRWfqOwfwSzBSA1/cwJANsEcsDAr1bDIn1";
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