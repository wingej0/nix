{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";

    # Home Manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, ... } @ inputs: 
  {
    nixosConfigurations = {
      # Virtual Machine
      nix-vm = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs;
          username = "wingej0";
          hostname = "nix-vm";
        };
        modules = [
          ./hosts
        ];
      };
    };
  };
}
