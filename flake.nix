{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Home Manager
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    
    impermanence.url = "github:nix-community/impermanence";

    # nixos-cosmic.url = "github:lilyinstarlight/nixos-cosmic";
    
  };

  outputs = { nixpkgs, ... } @ inputs: 
  {
    nixosConfigurations = {
      # Personal laptop (System76 Darter-Pro)
      darter-pro = nixpkgs.lib.nixosSystem {
        specialArgs = {
          inherit inputs;
          username = "wingej0";
          hostname = "darter-pro";
        };
        modules = [
          ./hosts
        ];
      };
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
